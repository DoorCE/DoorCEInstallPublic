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
  description = "Docker image for Postgres"
  type        = string
  default     = "postgres"
  nullable   = false
}

variable "container_version" {
  description = "Version of the Postgres container"
  type        = string
  default     = "16-alpine" # https://hub.docker.com/_/postgres/tags
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
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

variable "db_ckan" {
  description = "CKAN database name"
  type        = string
  default     = "ckandb"
}

variable "db_ckan_user" {
  description = "CKAN database user"
  type        = string
  default     = "ckandbuser"
}

variable "db_datastore" {
  description = "Datastore database name"
  type        = string
  default     = "datastore"
}

variable "db_datastore_userro" {
  description = "Datastore read-only user"
  type        = string
  default     = "datastore_ro"
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
