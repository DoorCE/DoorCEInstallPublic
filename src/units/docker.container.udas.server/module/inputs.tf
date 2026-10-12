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

variable "image_name" {
  description = "Docker image for Doorce Server"
  type        = string
  default     = "doorce/doorceserver"
  nullable   = false
}

variable "image_version" {
  description = "Version of the Doorce Server container"
  type        = string
  default     = "3a6d084" # https://hub.docker.com/r/doorce/doorceserver
  nullable    = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "internal_port" {
  description = "Internal port for the UDAS Server container"
  type        = number
  default     = 8080
}

variable "db_udas_server" {
  description = "PostgreSQL host name"
  type        = string
  default     = "db"
}

variable "db_udas_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432  
}

variable "db_udas_database" {
  description = "PostgreSQL database"
  type        = string
  default     = "default"
}

variable "db_udas_username" {
  description = "PostgreSQL user"
  type        = string
  default     = "default"
}

variable "db_udas_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "default"
  sensitive   = true
}

variable "server_site_url" {
  description = "Site URL for UDAS Server"
  type        = string
  nullable   = false
}

variable "service_site_path" {
  description = "Site path for UDAS Server"
  type        = string
  default     = "/udas"
  nullable   = false
}

variable "server_site_protocol" {
  description = "Site protocol for UDAS Server"
  type        = string
  default     = "http"
  nullable   = false
}

variable "ckan_authorization_token" {
  description = "Authorization token for CKAN"
  type        = string
  default     = "Authorization token for CKAN - change this"
  sensitive   = true
}

variable "ckan_internal_site_url" {
  description = "Site URL for CKAN"
  type        = string
  default     = "http://ckan:5000"
}

variable "keycloak_realm" {
  description = "Keycloak realm for authentication"
  type        = string
  default     = "udas"
  nullable   = false
}

variable "keycloak_auth_server_url" {
  description = "Keycloak authentication server URL"
  type        = string
}

variable "keycloak_ssl_required" {
  description = "Keycloak SSL required"
  type        = string
  default     = "external"
}

variable "keycloak_resource" {
  description = "Keycloak resource"
  type        = string
  default     = "udas-panel"
  nullable   = false
}

variable "keycloak_client_secret" {
  description = "Keycloak client secret"
  type        = string
  sensitive   = true
}

variable "keycloak_public_client" {
  description = "Keycloak public client"
  type        = bool
  default     = false
}

variable "keycloak_confidential_port" {
  description = "Keycloak confidential port"
  type        = number
  default     = 0
}

variable "keycloak_verify_token_audience" {
  description = "Keycloak verify token audience"
  type        = bool
  default     = false
}

variable "keycloak_server_resource" {
  description = "Keycloak server resource"
  type        = string
  default     = "udas-server"
  nullable   = false
}

variable "keycloak_server_client_secret" {
  description = "Keycloak server client secret"
  type        = string
  sensitive   = true
}

variable "udas_environment" {
  description = "Environment for UDAS Server"
  type        = string
  default     = "Production" # Change to "Development" for development environment
  nullable   = false
}

variable "udas_debug" {
  description = "Debug mode for UDAS Server"
  type        = bool
  default     = false
  nullable   = false
}

variable "udas_demo" {
  description = "Demo mode for UDAS Server"
  type        = bool
  default     = false
  nullable   = false
}

variable "udas_admin_name" {
  description = "Admin name for UDAS Server"
  type        = string
  default     = "udas-admin"
  nullable   = false
}

variable "udas_appgen_url" {
  description = "URL for UDAS App Generator"
  type        = string
}

variable "udas_appcmp_url" {
  description = "URL for UDAS App Compiler"
  type        = string
}
