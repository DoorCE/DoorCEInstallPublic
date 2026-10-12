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
  description = "Docker image for Doorce Midleware"
  type        = string
  default     = "doorceld/doorcemware"
}

variable "image_version" {
  description = "Version of the Doorce Mware container"
  type        = string
  default     = "2b22679"
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "internal_port" {
  description = "Internal port for the Doorce Mware container"
  type        = number
  default     = 8000
}

variable "server_site_protocol" {
  description = "Site protocol for Doorce Mware"
  type        = string
  default     = "http"
}

variable "service_site_path" {
  description = "Site path for Doorce Server"
  type        = string
  default     = "/mware"
  nullable   = false
}

variable "public_site_url" {
  description = "Site URL for Doorce Server"
  type        = string
}

variable "udas_server_internal_site_url" {
  description = "Site URL for Doorce Server"
  type        = string
}

variable "ckan_base_internal_site_api_url" {
  description = "Site URL for CKAN Server"
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
