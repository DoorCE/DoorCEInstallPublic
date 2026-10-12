variable "ssh_host" {
  description = "SSH host for Docker provider"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for Docker provider"
  type        = string
  default     = "ubuntu"
  nullable   = false
}

variable "ssh_port" {
  description = "SSH port for Docker provider"
  type        = string
  default     = "22"
  nullable   = false
}

variable "ssh_key_path" {
  description = "Path to SSH private key for Docker provider"
  type        = string
  default     = "/home/ubuntu/.ssh/id_ed25519"
  nullable   = false
}

####

variable "name" {
  description = "Name of the service"
  type        = string
}
