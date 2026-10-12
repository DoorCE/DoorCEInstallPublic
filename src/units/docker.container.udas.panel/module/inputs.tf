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
  description = "Docker image for Doorce Panel"
  type        = string
  default     = "doorce/doorcepanel"
  nullable   = false
}

variable "image_version" {
  description = "Version of the Doorce Panel container"
  type        = string
  default     = "6602a3a" # https://hub.docker.com/r/doorce/doorcepanel
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "host_port" {
  description = "Host port mapped to the UDAS Panel container"
  type        = number
  default     = 9000
}

variable "internal_port" {
  description = "Internal port for the UDAS Panel container"
  type        = number
  default     = 9000
}

variable "server_site_url" {
  description = "Site URL for UDAS panel"
  type        = string
  # default     = "udas-panel"
}

variable "server_site_protocol" {
  description = "Site protocol for UDAS Server"
  type        = string
  default     = "http"
}

variable "service_site_path" {
  description = "Site path for UDAS Server"
  type        = string
  default     = "/panel"
  nullable   = false
}

variable "udas_server_public_site_url" {
  description = "Site URL for UDAS Server"
  type        = string
  # default     = "udas-server"
}

variable "udas_platform_public_url" {
  description = "Public URL for UDAS Platform"
  type        = string
  # default     = "udas-platform"
}

variable "keycloak_server_url" {
  description = "Keycloak server URL"
  type        = string
}

variable "keycloak_realm" {
  description = "Keycloak realm"
  type        = string
  default     = "udas"
  nullable   = false
}

variable "keycloak_client" {
  description = "Keycloak client ID"
  type        = string
  default     = "udas-panel"
  nullable   = false
}

variable "keycloak_client_secret" {
  description = "Keycloak client secret"
  type        = string
  sensitive   = true
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
