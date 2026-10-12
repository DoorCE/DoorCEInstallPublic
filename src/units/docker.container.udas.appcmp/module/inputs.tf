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
  description = "Name of the Docker container"
  type        = string
}

variable "container_platform" {
  description = "Container platform (e.g., linux/amd64, linux/arm64)"
  type        = string
  default     = "linux/amd64"
}

variable "image_name" {
  description = "Base image for the container (e.g., doorce/doorcegenerator)"
  type        = string
  default     = "doorce/doorceappdeploy"
  nullable   = false
}

variable "image_version" {
  description = "Version tag for the container image (e.g., db53811)"
  type        = string
  default     = "8927c32" # https://hub.docker.com/r/doorce/doorceappdeploy
  nullable   = false
}

variable "networks" {
  description = "List of networks where this container should be connected"
  type        = list(string)
}

variable "network_for_clients" {
  description = "Network to which clients (e.g., Traefik) will connect to access the service provided by this container"
  type        = string
}

variable "service_port" {
  description = "Internal port for the UDAS App Generator container"
  type        = number
  default     = 8080
}

variable "service_protocol" {
  description = "Protocol for the UDAS App Generator service (e.g., http)"
  type        = string
  default     = "http"
}

variable "udas_server_url" {
  description = "URL for UDAS Server (used by the app generator to communicate with the server)"
  type        = string
}

variable "udas_platform_url" {
  description = "URL for UDAS Platform (used by the app generator to communicate with the platform)"
  type        = string
}

variable "udas_appgen_url" {
  description = "URL for UDAS App Generator"
  type        = string
}

variable "udas_apprepo_shared_volume_name" {
  description = "Name of the shared volume for UDAS App Repository"
  type        = string
}

variable "udas_apprepo_shared_volume_path" {
  description = "Path to the shared volume for UDAS App Repository"
  type        = string
  default     = "/var/udas/apprepo"
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

variable "server_site_protocol" {
  description = "Site protocol for UDAS Server"
  type        = string
  default     = "http"
}

variable "server_site_url" {
  description = "Site URL for UDAS platform"
  type        = string
  # default     = "udas-platform"
}
