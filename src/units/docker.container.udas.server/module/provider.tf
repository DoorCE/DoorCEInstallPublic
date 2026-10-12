provider "docker" {
  host = "ssh://${var.ssh_user}@${var.ssh_host}:${var.ssh_port}"
  ssh_opts = ["-o", "IdentityFile=${var.ssh_key_path}", "-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}