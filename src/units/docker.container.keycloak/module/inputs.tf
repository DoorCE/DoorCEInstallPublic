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
  description = "Docker image for Keycloak"
  type        = string
  default     = "keycloak/keycloak"
  nullable   = false
}

variable "container_version" {
  description = "Version of the Keycloak container image"
  type        = string
  default     = "26.2.5" # https://hub.docker.com/r/keycloak/keycloak/tags
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

# variable "host_port" {
#   description = "Host port mapped to Keycloak"
#   type        = number
#   default     = 8080
# }

variable "internal_port" {
  description = "Internal port for Keycloak"
  type        = number
  default     = 8080
}

variable "data_path" {
  description = "Path on the host VM to map as Keycloak data volume"
  type        = string
  default     = "/opt/keycloak/data"
}

variable "keycloak_admin_user" {
  description = "Keycloak admin user"
  type        = string
  default     = "admin"
}

variable "server_site_protocol" {
  description = "Protocol for Keycloak Server"
  type        = string
}

variable "server_site_url" {
  description = "URL for Keycloak Server"
  type        = string
}

variable "service_site_path" {
  description = "Site path for Keycloak Service"
  type        = string
  default     = "/keycloak"
  nullable    = false
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
