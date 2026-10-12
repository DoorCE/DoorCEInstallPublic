variable "name" {
  description = "Name of the service"
  type        = string
}

variable "container_platform" {
  description = "Platform for the container"
  type        = string
  default     = "linux/amd64"
}

variable "container_image" {
  description = "Docker image for Datapusher"
  type        = string
  default     = "ckan/ckan-base-datapusher"
  nullable   = false
}

variable "container_version" {
  description = "Version of the Datapusher container"
  type        = string
  default     = "0.0.21"
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "internal_port" {
  description = "Internal port for Datapusher"
  type        = number
  default     = 8800
}

variable "service_protocol" {
  description = "Protocol for the service (http or https)"
  type        = string
  default     = "http"
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
