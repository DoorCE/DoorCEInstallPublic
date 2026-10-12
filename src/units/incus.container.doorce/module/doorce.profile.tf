resource "incus_storage_volume" "docker_data" {
  depends_on = [
    incus_storage_pool.local_dir,
  ]
  name        = "doorce-docker-data"
  pool        = "local-dir"
  type        = "custom"
  description = "Persistent storage for Docker engine"
}

resource "incus_storage_volume" "user_home" {
  depends_on = [
    incus_storage_pool.local_dir,
  ]
  name        = "doorce-user-home"
  pool        = "local-dir"
  type        = "custom"
  description = "Persistent home directory for ubuntu user"
}

resource "incus_profile" "doorce" {
  depends_on = [
    incus_storage_volume.docker_data,
    incus_storage_volume.user_home,
  ]
  name        = "doorce"
  description = "Profile for DoorCE containers with pre-installed tools"

  config = {
    # Path to your cloud-init configuration file
    "user.user-data" = templatefile("${path.module}/doorce.profile.cloud-init.yaml", {
      ssh_public_key = var.ssh_public_key
    })
    "security.nesting" = true
  }

  # Root disk device
  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = "local-dir"
    }
  }

  # Network interface with management ACLs
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = incus_network.networks["incus-udas"].name
      name    = "eth0"
    }
  }

  device {
    name = "http_proxy"
    type = "proxy"
    properties = {
      listen  = "tcp:0.0.0.0:80"
      connect = "tcp:127.0.0.1:80"
    }
  }

  device {
    name = "https_proxy"
    type = "proxy"
    properties = {
      listen  = "tcp:0.0.0.0:443"
      connect = "tcp:127.0.0.1:443"
    }
  }

  device {
    name = "docker_storage"
    type = "disk"
    properties = {
      pool   = "local-dir"
      source = incus_storage_volume.docker_data.name
      path   = "/var/lib/docker"
    }
  }

  device {
    name = "home_storage"
    type = "disk"
    properties = {
      pool   = "local-dir"
      source = incus_storage_volume.user_home.name
      path   = "/home/ubuntu"
    }
  }

}