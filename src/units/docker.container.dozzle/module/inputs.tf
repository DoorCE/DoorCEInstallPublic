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
  description = "Docker image for Dozzle container"
  type        = string
  default     = "amir20/dozzle"
  nullable   = false
}

variable "container_version" {
  description = "Version of the Dozzle container"
  type        = string
  default     = "v10.6.10"  # https://github.com/amir20/dozzle/releases
  nullable   = false
}

variable "network" {
  description = "network for the container"
  type        = string
}

variable "internal_port" {
  description = "Internal port for Dozzle container"
  type        = number
  default     = 8080
}

variable "service_site_url" {
  description = "Site URL for the Dozzle service"
  type        = string
  default     = "dozzle.localhost"
}

variable "service_site_path" {
  description = "Site path for the Dozzle service"
  type        = string
  default     = "/dozzle"
  nullable   = false
}

variable "service_site_protocol" {
  description = "Protocol for the Dozzle site"
  type        = string
  default     = "http"
}

variable "traefik_auth_credentials_username" {
  description = "Credentials for Traefik Basic Auth username"
  type        = string
  sensitive   = true
}

variable "traefik_auth_credentials_password" {
  description = "Credentials for Traefik Basic Auth password"
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

variable "oauth2_proxy_site_path" {
  description = "Site path for the OAuth2 Proxy service"
  type        = string
  nullable   = false
}