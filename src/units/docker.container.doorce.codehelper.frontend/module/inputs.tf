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

###

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
  description = "Docker image name for DoorCE CodeHelper Frontend"
  type        = string
  default     = "alex1989d/doorce-codehelper-streamlit" #alex1989d/doorce-codehelper-flutter
  nullable   = false
}

variable "image_version" {
  description = "Version of the DoorCE CodeHelper Frontend container"
  type        = string
  default     = "2026-08-10" #  https://hub.docker.com/r/alex1989d/doorce-codehelper-streamlit --- IGNORE ---
  nullable   = false  
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "internal_port" {
  description = "Internal port for DoorCE CodeHelper Frontend container"
  type        = number
  default     = 8501 #80
}

variable "server_site_protocol" {
  description = "Site protocol for Doorce CodeHelper Frontend"
  type        = string
  default     = "http"
}

variable "server_site_url" {
  description = "Site URL for Doorce CodeHelper Frontend"
  type        = string
}

variable "service_site_path" {
  description = "Site path for Doorce CodeHelper Frontend"
  type        = string
  default     = "/codehelper"
  nullable   = false
}

variable "doorce_codehelper_backend_internal_url" {
  description = "Internal URL for DoorCE CodeHelper Backend"
  type        = string
}
