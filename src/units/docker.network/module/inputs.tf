variable "name" {
  description = "The name of the network"
  type        = string
}

variable "driver" {
  description = "The driver to use for the network"
  type        = string
  default     = "bridge"
}

variable "internal" {
  description = "Whether the network is internal or not"
  type        = bool
  default     = true
}


variable "ssh_host" {
  description = "SSH host for Docker provider"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for Docker provider"
  type        = string
  default     = "ubuntu"
}

variable "ssh_port" {
  description = "SSH port for Docker provider"
  type        = string
  default     = "22"
}

variable "ssh_key_path" {
  description = "Path to SSH private key for Docker provider"
  type        = string
  default     = "/home/ubuntu/.ssh/id_ed25519"
}
