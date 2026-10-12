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
  description = "Base image for the container (e.g., alex1989d/doorce-codehelper-backend)"
  type        = string
  default     = "alex1989d/doorce-codehelper-backend"
  nullable   = false
}

variable "image_version" {
  description = "Version tag for the container image (e.g., db53811)"
  type        = string
  default     = "2026-08-10" # https://hub.docker.com/r/alex1989d/doorce-codehelper-backend
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
  description = "Internal port for the service provided by this container (e.g., 8000)"
  type        = number
  default     = 8000 # Hardcoded in the app, see https://github.com/DoorCE/DoorCECodeHelper/blob/main/docker/backend.Dockerfile
}

variable "service_protocol" {
  description = "Protocol for the service provided by this container (e.g., http)"
  type        = string
  default     = "http"
}

variable "ckan_base_internal_url" {
  description = "Internal URL for CKAN Base container (e.g., http://ckan-base:5000)"
  type        = string
}