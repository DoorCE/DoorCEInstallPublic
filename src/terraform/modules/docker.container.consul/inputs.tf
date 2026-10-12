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
  description = "Docker image for Consul"
  type        = string
  default     = "consul"
}

variable "container_version" {
  description = "Version of the Consul image"
  type        = string
  default     = "1.15.4" # https://hub.docker.com/_/consul/tags
}

variable "network" {
  description = "network for the container"
  type        = string
}

variable "host_http_api_port" {
  description = "Host HTTP port for Consul"
  type        = number
  default     = 8500
}

variable "internal_http_api_port" {
  description = "Internal HTTP port for the Consul"
  type        = number
  default     = 8500
}

variable "data_path" {
  description = "Path on the host VM to map as Consul data volume"
  type        = string
  default     = "/consul/data"
}

variable "service_site_url" {
  description = "URL for the Consul site"
  type        = string
  default     = "consul.localhost"
}

variable "service_site_path" {
  description = "Site path for the Consul service"
  type        = string
  default     = ""
}

variable "service_site_protocol" {
  description = "Protocol for the Consul site"
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