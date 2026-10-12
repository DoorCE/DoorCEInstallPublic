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
  default     = "doorce/doorcegenerator"
  nullable   = false
}

variable "image_version" {
  description = "Version tag for the container image (e.g., db53811)"
  type        = string
  default     = "0095f17" # https://hub.docker.com/r/doorce/doorcegenerator/tags
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

variable "db_udas_server" {
  description = "UDAS server database name"
  type        = string
}

variable "db_udas_port" {
  description = "UDAS server database port"
  type        = number
}

variable "db_udas_database" {
  description = "UDAS server database name"
  type        = string
}

variable "db_udas_username" {
  description = "UDAS server database username"
  type        = string
}

variable "db_udas_password" {
  description = "UDAS server database password"
  type        = string
  sensitive   = true
}

variable "udas_debug" {
  description = "Debug mode for UDAS Server"
  type        = bool
  default     = false
  nullable   = false
}

variable "udas_environment" {
  description = "Environment for UDAS Server"
  type        = string
  default     = "Production" # Change to "Development" for development environment
  nullable   = false
}
