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
  description = "Docker image for Traefik"
  type        = string
  default     = "traefik"
  nullable   = false
}

variable "container_version" {
  description = "Version of the Traefik container"
  type        = string
  default     = "3.7.16" # https://github.com/traefik/traefik/tags
  nullable   = false
}

variable "network_public" {
  description = "Public network for external access"
  type        = string
}

variable "host_http_port" {
  description = "HTTP port for Traefik"
  type        = number
  default     = 80
}

variable "host_https_port" {
  description = "HTTPS port for Traefik"
  type        = number
  default     = 443
}

variable "internal_http_port" {
  description = "Internal HTTP port for Traefik"
  type        = number
  default     = 80
}

variable "internal_https_port" {
  description = "Internal HTTPS port for Traefik"
  type        = number
  default     = 443
}

variable "host_dashboard_port" {
  description = "Dashboard port for Traefik"
  type        = number
  default     = 8080
}

variable "internal_dashboard_port" {
  description = "Internal dashboard port for Traefik"
  type        = number
  default     = 8080
}

variable "server_site_protocol" {
  description = "Protocol for the Traefik site"
  type        = string
  default     = "http"
}

variable "server_site_url" {
  description = "URL for the Traefik site"
  type        = string
  default     = "traefik.localhost"
}

variable "service_site_path" {
  description = "Site path for Traefik Server"
  type        = string
  default     = "/traefik"
  nullable   = false
}

variable "https_cert" {
  description = "Path to the HTTPS CERT file"
  type        = string
  default     = "https.cert"
  sensitive = true
}
variable "https_key" {
  description = "Path to the HTTPS key file"
  type        = string
  default     = "https.key"
  sensitive = true
}

variable "traefik_dynamic_conf" {
  description = "Dynamic configuration for Traefik"
  type        = string
  default     = ""
}

variable "traefik_static_conf" {
  description = "Static configuration for Traefik"
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

variable "ip_white_list" {
  type        = list(string)
  description = "List of allowed IP CIDRs for Dozzle access"
  default = [
    "0.0.0.0/0",
  ]
  nullable   = false
}
