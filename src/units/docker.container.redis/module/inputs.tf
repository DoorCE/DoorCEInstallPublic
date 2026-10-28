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
  description = "Docker image for Redis"
  type        = string
  default     = "redis"
  nullable   = false
}

variable "container_version" {
  description = "Version of the Redis container"
  type        = string
  default     = "8.10.3" #https://github.com/redis/redis/tags
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "host_port" {
  description = "Host port mapped to Redis port (6379) - default null"
  type        = number
  default     = 6379
}

variable "internal_port" {
  description = "Internal port for Redis"
  type        = number
  default     = 6379
}

variable "data_path" {
  description = "Path on the host VM to map as Redis data volume"
  type        = string
  default     = "/data"
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
