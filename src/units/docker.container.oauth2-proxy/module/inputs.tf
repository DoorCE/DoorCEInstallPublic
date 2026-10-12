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
  description = "Docker image for OAuth2 Proxy container"
  type        = string
  default     = "quay.io/oauth2-proxy/oauth2-proxy"
  nullable   = false
}

variable "container_version" {
  description = "Version of the OAuth2 Proxy container"
  type        = string
  default     = "v7.15.2"  # https://github.com/oauth2-proxy/oauth2-proxy/releases
  nullable   = false
}

variable "network" {
  description = "network for the container"
  type        = string
}

variable "internal_port" {
  description = "Internal port for OAuth2 Proxy container"
  type        = number
  default     = 4180
}

variable "service_site_protocol" {
  description = "Protocol for the OAuth2 Proxy site"
  type        = string
  default     = "http"
}

variable "service_site_url" {
  description = "Site URL for the OAuth2 Proxy service"
  type        = string
  default     = "oauth2-proxy.localhost"
}

variable "service_site_path" {
  description = "Site path for the OAuth2 Proxy service"
  type        = string
  nullable   = false
}

variable "keycloak_client_id" {
  description = "Keycloak client ID for OAuth2 Proxy"
  type        = string
  default     = "infra-proxy"
  nullable   = false
}

variable "keycloak_client_secret" {
  description = "Keycloak client secret for OAuth2 Proxy"
  type        = string
  sensitive   = true
  nullable   = false
}

variable "keycloak_realm" {
  description = "Keycloak realm for OAuth2 Proxy"
  type        = string
  default     = "infra"
  nullable   = false
}