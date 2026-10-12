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
  description = "Docker image for Solr"
  type        = string
  default     = "ckan/ckan-solr"
  nullable   = false
}

variable "container_version" {
  description = "Version of the Solr container"
  type        = string
  default     = "2.10-solr9"
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "host_port" {
  description = "Port available on the host VM to map to Solr port (8983)"
  type        = number
  default     = 8983
}

variable "internal_port" {
  description = "Internal port for Solr"
  type        = number
  default     = 8983
}

variable "data_path" {
  description = "Path to data directory for Solr"
  type        = string
  default     = "/var/solr"
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
