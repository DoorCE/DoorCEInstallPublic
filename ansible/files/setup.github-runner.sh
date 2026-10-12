#!/bin/bash
set -e          # Stop on any error
set -u          # Stop, if you try to use an undefined variable
set -o pipefail # Stop, if a command within a pipe fails

GH_URL=""
GH_TOKEN=""
ADDRESS="172.16.16.1/28"
RUNNER_VERSION="2.333.1"
RUNNER_HASH="18f8f68ed1892854ff2ab1bab4fcaa2f5abeedc98093b6cb13638991725cab74"
CONTAINER_NAME="github-runner"
NODE_MAJOR=24
HOSTNAME=$(hostname)

# --- USAGE ---
usage() {
    echo "Usage: sudo bash $0 --gh-url <URL> --gh-token <TOKEN> [--address <IP/MASK>]"
    echo "Example: sudo bash $0 --gh-url https://github.com/user/repo --gh-token ABC123 [--address 172.16.17.1/29]"
    exit 1
}

# --- INSTALLING LXC ---
install_lxc() {
    echo "=== Installing LXC and dependencies ==="
    sudo apt update
    sudo apt install -y lxc lxc-templates bridge-utils vlan tree ipcalc python3-apt curl
}

# --- CONFIGURING LXC ---
setup_lxc_network() {
    ADDRESS=$1
    echo "=== Setting up LXC with address: $ADDRESS ==="
    LXC_ADDR=$(ipcalc $ADDRESS | awk '/Address:/ {print $2}')
    LXC_NETMASK=$(ipcalc $ADDRESS | awk '/Netmask:/ {print $2}')
    LXC_NETWORK=$(ipcalc $ADDRESS | awk '/Network:/ {print $2}')
    LXC_DHCP_MIN=$(ipcalc $ADDRESS | awk '/HostMin:/ { split($2, a, "."); print a[1]"."a[2]"."a[3]"."(a[4]+1) }')
    LXC_DHCP_MAX_VAL=$(ipcalc $ADDRESS | awk '/HostMax:/ { split($2, a, "."); print a[1]"."a[2]"."a[3]"."(a[4]) }')
    LXC_DHCP_MAX="$(ipcalc $ADDRESS | awk '/Hosts\/Net:/ {print $2-1}')"
    if [ "$LXC_DHCP_MAX" -lt 4 ]; then
        echo "Calculated DHCP max hosts ($LXC_DHCP_MAX) is less than 4. Adjusting to 4 for minimal functionality (minimal mask is /29 for 6 usable hosts - minus 1 for gateway)."
        exit 1
    fi

    install -m 644 -o root -g root /dev/null /etc/default/lxc-net
cat <<EOF | sudo tee /etc/default/lxc-net
USE_LXC_BRIDGE="true"
LXC_BRIDGE="lxcbr0"
LXC_ADDR="$LXC_ADDR"
LXC_NETMASK="$LXC_NETMASK"
LXC_NETWORK="$LXC_NETWORK"
LXC_DHCP_RANGE="$LXC_DHCP_MIN,$LXC_DHCP_MAX_VAL"
LXC_DHCP_MAX="$LXC_DHCP_MAX"
LXC_DOMAIN="lxc"
EOF
    sudo systemctl restart lxc-net
}

# --- CONFIGURING SUDOERS ---
setup_sudo() {
    HOST_USER=$1
    echo "=== Configuring NOPASSWD for ${HOST_USER} ==="
    echo "${HOST_USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${HOST_USER}
    sudo chmod 0440 /etc/sudoers.d/${HOST_USER}
}

# --- CONTAINER RECREATION ---
recreate_container() {
    CONTAINER_NAME=$1
    echo "=== Recreating container: $CONTAINER_NAME ==="
    sudo lxc-destroy -n "$CONTAINER_NAME" --force 2>/dev/null || true
    echo "Creating new container..."
    sudo lxc-create --name "$CONTAINER_NAME" --template download -- --dist ubuntu --release noble --arch amd64
}

# --- CONTAINER SETUP - installing cloud-init ---
prepare_container() {
    CONTAINER_NAME=$1

    echo "=== Initializing cloud-init and Network ==="
    sudo lxc-start -n "$CONTAINER_NAME"
    # Wait for network and install cloud-init
    sudo lxc-attach --name "$CONTAINER_NAME" -- sh -c '
        until ip -4 addr show eth0 | grep -q inet
        do
            sleep 1
        done
        apt update
        apt install cloud-init isc-dhcp-client -y
    '
    sudo lxc-stop -n "$CONTAINER_NAME"
}

# --- GENERATING USER-DATA ---
cloud_init_for_container() {
    CONTAINER_NAME=$1
    RUNNER_VERSION=$2
    RUNNER_HASH=$3
    HOST_USER=$4
    GH_URL=$5
    GH_TOKEN=$6
    NODE_MAJOR=$7
    HOSTNAME=$8

    ROOTFS="/var/lib/lxc/$CONTAINER_NAME/rootfs"
    SEED_DIR="$ROOTFS/var/lib/cloud/seed/nocloud"
    sudo mkdir -p "$SEED_DIR"
    cat <<EOF | sudo tee "${SEED_DIR}/user-data"
#cloud-config
package_update: true
package_upgrade: true
packages:
- curl
- git
- jq
- yq
- build-essential
- libicu-dev
- openssh-client
- tree
- ansible

# Use the existing 'ubuntu' user instead of creating a new one
users:
- default

runcmd:
- |
    echo "Installing Node.js 24 (LTS candidates)..."
    mkdir -p /etc/apt/keyrings
    install -m 600 -o root -g root /dev/null /tmp/nodesource.key
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key -o /tmp/nodesource.key
    # sha256sum need two spaces before filename to work correctly when reading from pipe
    ACTUAL_HASH=\$(sha256sum  /tmp/nodesource.key | awk '{print \$1}')
    EXPECTED_HASH="b42e0321dabdc24e892115da705cf061167eac12a317f23d329862d0aa0a271d"
    if [ "\$ACTUAL_HASH" != "\$EXPECTED_HASH" ]; then
        echo "🚨 ALARM: Key is not authentic!"
        exit 1
    else
        echo "✅ Key is authentic. Installing..."
        install -m 644 -o root -g root /dev/null /etc/apt/keyrings/nodesource.gpg
        cat /tmp/nodesource.key | gpg --dearmor | sudo tee /etc/apt/keyrings/nodesource.gpg > /dev/null
    fi
    install -m 644 -o root -g root /dev/null /etc/apt/sources.list.d/nodesource.list
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list    
    
    apt update
    apt install -y nodejs
    node -v
- |
    echo "Configuring SSH key"
    [ -e "/home/ubuntu/.ssh" ] && rm -rf /home/ubuntu/.ssh
    sudo -u ubuntu ln -s /opt/github-runner/ssh /home/ubuntu/.ssh
    [ ! -f "/home/ubuntu/.ssh/id_ed25519" ] && sudo -u ubuntu ssh-keygen -f /home/ubuntu/.ssh/id_ed25519 -t ed25519 -N ""
    echo "Configuring Incus directory"
    [ ! -d "/home/ubuntu/.config" ] && sudo -u ubuntu mkdir -p /home/ubuntu/.config
    [ -e "/home/ubuntu/.config/incus" ] && rm -rf /home/ubuntu/.config/incus
    sudo -u ubuntu ln -s /opt/github-runner/incus /home/ubuntu/.config/incus
- |
    echo "Get the IP of the host bridge (default gateway)"
    GW_IP=\$(ip route | grep default | awk '{print \$3}')
    SSH_DIR="/home/ubuntu/.ssh"
    echo "Detected gateway IP: \$GW_IP"
    install -D -m 600 -o ubuntu -g ubuntu /dev/null \$SSH_DIR/config
    install -m 600 -o ubuntu -g ubuntu /dev/null \$SSH_DIR/known_hosts
    cat <<SSHCONFIG > \$SSH_DIR/config
    Host ${HOSTNAME}
        HostName \$GW_IP
        User ${HOST_USER}
        IdentityFile ~/.ssh/id_ed25519
    SSHCONFIG
    sudo -u ubuntu sh -c "ssh-keygen -R \$GW_IP"
    sudo -u ubuntu sh -c "ssh-keyscan -H \$GW_IP >> \$SSH_DIR/known_hosts"

- |
    echo "Register and setup GitHub Runner as a service..."
    mkdir -p /home/ubuntu/actions-runner
    cd /home/ubuntu/actions-runner
    curl -o runner.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
    echo "Verifying runner checksum..."
    echo "${RUNNER_HASH}  runner.tar.gz" | shasum -a 256 -c
    tar xzf ./runner.tar.gz
    chown -R ubuntu:ubuntu /home/ubuntu/actions-runner
    sudo -u ubuntu sh -c "echo 'FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true' >> /home/ubuntu/actions-runner/.env"
    sudo -u ubuntu /home/ubuntu/actions-runner/config.sh \
        --unattended \
        --replace \
        --url ${GH_URL} \
        --token ${GH_TOKEN} \
        --name ${HOSTNAME} \
        --labels "self-hosted,linux,x64,${HOSTNAME}"
    cd /home/ubuntu/actions-runner
    ./svc.sh install ubuntu
    ./svc.sh start
EOF

    echo "instance-id: $CONTAINER_NAME" | sudo tee "${SEED_DIR}/meta-data"
    echo "network: {config: disabled}" | sudo tee "$ROOTFS/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"
}
# --- LXC AUTOSTART ---
setup_container_parameters() {
    CONTAINER_NAME=$1
    ROOTFS="/var/lib/lxc/$CONTAINER_NAME/rootfs"
    TARGET_HOME="$ROOTFS/home/ubuntu"
    CONTAINER_UID=$(sudo stat -c %u "$TARGET_HOME")
    CONTAINER_GID=$(sudo stat -c %g "$TARGET_HOME")
    LXC_CONFIG="/var/lib/lxc/$CONTAINER_NAME/config"
    echo "#Configuring LXC autostart and bind mount for GitHub Runner data directory" | sudo tee -a "$LXC_CONFIG"
    sudo sed -i '/lxc.start.auto/d' "$LXC_CONFIG"
    echo "lxc.start.auto = 1" | sudo tee -a "$LXC_CONFIG"
    sudo sed -i '/lxc.start.delay/d' "$LXC_CONFIG"
    echo "lxc.start.delay = 5" | sudo tee -a "$LXC_CONFIG"
    sudo install -d -m 700 -o "$CONTAINER_UID" -g "$CONTAINER_GID" /opt/github-runner/state
    sudo install -d -m 700 -o "$CONTAINER_UID" -g "$CONTAINER_GID" /opt/github-runner/incus
    sudo install -d -m 700 -o "$CONTAINER_UID" -g "$CONTAINER_GID" /opt/github-runner/ssh
    sudo sed -i '/lxc.mount.entry/d' "$LXC_CONFIG"
    echo "lxc.mount.entry = /opt/github-runner opt/github-runner none bind,create=dir 0 0" | sudo tee -a "$LXC_CONFIG"
}

final_boot_container() {
    CONTAINER_NAME=$1
    echo "=== Final boot and Monitoring ==="
    sudo lxc-start -n "$CONTAINER_NAME"
    sudo lxc-attach --name "$CONTAINER_NAME" -- tail -F /var/log/cloud-init-output.log &
    LOG_PID=$!
    sudo lxc-attach --name "$CONTAINER_NAME" -- cloud-init status --wait
    kill $LOG_PID 2>/dev/null
}

get_ssh_key() {
    # Allow host user to SSH into themselves
    if ! sudo grep -q "$(cat "/opt/github-runner/ssh/id_ed25519.pub")" "$HOST_SSH_DIR/authorized_keys" 2>/dev/null
    then
        cat "/opt/github-runner/ssh/id_ed25519.pub" | sudo tee -a "$HOST_SSH_DIR/authorized_keys" > /dev/null
    fi
}

# Parameters parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        --gh-url)
            GH_URL="$2"
            shift 2
            ;;
        --gh-token)
            GH_TOKEN="$2"
            shift 2
            ;;
        --address)
            ADDRESS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown parameter: $1"
            usage
            ;;
    esac
done

if [ -z "$GH_URL" ] || [ -z "$GH_TOKEN" ]; then
    echo "Error: --gh-url and --gh-token are required."
    usage
fi

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root."
    usage
fi

echo "Running with: URL=$GH_URL, Token=$GH_TOKEN, Address=$ADDRESS"
# --- SYSTEM DETECTION ---
# Detect who ran the script to set up host SSH correctly
HOST_USER=${SUDO_USER:-${USER}}
HOST_HOME=$(getent passwd "$HOST_USER" | cut -d: -f6)
HOST_SSH_DIR="$HOST_HOME/.ssh"

setup_sudo "$HOST_USER"
install_lxc
recreate_container "$CONTAINER_NAME"
setup_container_parameters "$CONTAINER_NAME"
setup_lxc_network "$ADDRESS"
prepare_container "$CONTAINER_NAME"
cloud_init_for_container "$CONTAINER_NAME" "$RUNNER_VERSION" "$RUNNER_HASH" "$HOST_USER" "$GH_URL" "$GH_TOKEN" "$NODE_MAJOR" "$HOSTNAME"
final_boot_container "$CONTAINER_NAME"
get_ssh_key "$HOST_SSH_DIR"

echo ""
echo "=== CONFIGURATION COMPLETE ==="
sudo lxc-info -n "$CONTAINER_NAME"
