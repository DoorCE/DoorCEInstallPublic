variable "name" {
  description = "Name of the service"
  type        = string
}

variable "container_platform" {
  description = "Platform for the container"
  type        = string
  default     = "linux/amd64"
}

variable "image_name" {
  description = "Docker image name for DoorCE Portal"
  type        = string
  default     = "doorceld/doorceportal"
  nullable   = false
}

variable "image_version" {
  description = "Version of the DoorCE Portal container"
  type        = string
  default     = "ee378b6" # https://hub.docker.com/r/doorceld/doorceportal
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "internal_port" {
  description = "Internal port for DoorCE Portal"
  type        = number
  default     = 80
}

variable "server_site_protocol" {
  description = "Site protocol for Doorce Portal (http or https)"
  type        = string
  default     = "http"
}

variable "service_site_path" {
  description = "Site path for Doorce Portal"
  type        = string
  default     = ""
  nullable   = false
}

variable "server_site_url" {
  description = "Site URL for Doorce Portal"
  type        = string
}

variable "middleware_url" {
  description = "URL for middleware integration"
  type        = string
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

variable container_enabled {
  description = "Enable or disable the container"
  type        = bool
  default     = true
  nullable    = false
}