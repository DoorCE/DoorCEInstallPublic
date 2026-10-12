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
  description = "Name of the service"
  type        = string
}

variable "container_platform" {
  description = "Platform for the container"
  type        = string
  default     = "linux/amd64"
}

variable "image_name" {
  description = "Docker image for Postgres"
  type        = string
  default     = "postgres"
  nullable   = false
}

variable "image_version" {
  description = "Version of the Postgres container"
  type        = string
  default     = "17.4-bookworm" # https://hub.docker.com/_/postgres/tags
  nullable   = false
}

variable "network_for_clients" {
  description = "Network to connect the container to for client access"
  type        = string
}

variable "host_port" {
  description = "Host port mapped to Postgres port (5432)"
  type        = number
  default     = 5432
}

variable "internal_port" {
  description = "Internal port for Postgres"
  type        = number
  default     = 5432
}

variable "data_path" {
  description = "Path on the host VM to map as Postgres data volume"
  type        = string
  default     = "/var/lib/postgresql/data"
}

variable "db_postgres" {
  description = "Postgres database name"
  type        = string
  default     = "postgres"
}

variable "db_postgres_user" {
  description = "Postgres database user"
  type        = string
  default     = "postgres"
}

variable "db_udas_database" {
  description = "UDAS server database name"
  type        = string
  default     = "udasdb"
}

variable "db_udas_username" {
  description = "UDAS server database user"
  type        = string
  default     = "udasuser"
}
