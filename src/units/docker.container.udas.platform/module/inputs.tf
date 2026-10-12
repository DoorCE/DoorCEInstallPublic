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

####

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
  description = "Docker image for Doorce Platform"
  type        = string
  default     = "doorce/doorceplatform"
  nullable   = false
}

variable "image_version" {
  description = "Version of the Doorce Platform container"
  type        = string
  default     = "93f67ac" # https://hub.docker.com/r/doorce/doorceplatform
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "host_port" {
  description = "Host port mapped to the UDAS Platform container"
  type        = number
  default     = 9000
}

variable "internal_port" {
  description = "Internal port for the UDAS Platform container"
  type        = number
  default     = 9000
}

variable "server_site_url" {
  description = "Site URL for UDAS platform"
  type        = string
  # default     = "udas-platform"
}

variable "server_site_protocol" {
  description = "Site protocol for UDAS Server"
  type        = string
  default     = "http"
}

variable "service_site_path" {
  description = "Site path for UDAS Server"
  type        = string
  default     = "/platform"
  nullable   = false
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

variable "udas_server_url" {
  description = "Site URL for UDAS Server"
  type        = string
  # default     = "udas-server"
}

variable "udas_apprepo_shared_volume_name" {
  description = "Name of the shared volume for UDAS App Repository"
  type        = string
}

variable "udas_apprepo_shared_volume_path" {
  description = "Path to the shared volume for UDAS App Repository"
  type        = string
  default     = "/app/build/web/apps"
}