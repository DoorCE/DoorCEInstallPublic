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
  description = "Docker image for CKAN Base"
  type        = string
  default     = "ckan/ckan-base"
  nullable   = false
}

variable "container_version" {
  description = "Version of the CKAN Base container"
  type        = string
  default     = "2.11"
  nullable   = false
}

variable "networks" {
  description = "List of networks to connect the container to"
  type        = list(string)
}

variable "host_port" {
  description = "Port available on the host VM to map to CKAN Base"
  type        = number
  default     = 5000
}

variable "internal_port" {
  description = "Internal port for CKAN Base"
  type        = number
  default     = 5000
}

variable "ckan_storage_path" {
  description = "Path to storage directory for CKAN"
  type        = string
  default     = "/var/lib/ckan"
}

variable "ckan_pip_cache_path" {
  description = "Path to pip cache directory for CKAN"
  type        = string
  default     = "/root/.cache/pip"
}

variable "ckan_site_packages_path" {
  description = "Path to site-packages directory for CKAN"
  type        = string
  default     = "/usr/lib/python3.10/site-packages"
}

# variable "ckan_site_protocol" {
#   description = "CKAN site protocol"
#   type        = string
#   default     = "http"
# }

# variable "ckan_site_url" {
#   description = "CKAN site URL"
#   type        = string
#   default     = "localhost:5000"
# }

variable "db_postgres_user" {
  description = "PostgreSQL user for CKAN"
  type        = string
  default     = "ckan_default"
}

variable "db_postgres_password" {
  description = "PostgreSQL password for CKAN"
  type        = string
  default     = "ckan_default"
  sensitive   = true
}

variable "db_postgres" {
  description = "PostgreSQL database for CKAN"
  type        = string
  default     = "ckan_default"
}

variable "db_ckan_user" {
  description = "CKAN user for PostgreSQL"
  type        = string
  default     = "ckan_default"
}

variable "db_ckan_password" {
  description = "CKAN password for PostgreSQL"
  type        = string
  default     = "ckan_default"
  sensitive   = true
}

variable "db_ckan" {
  description = "CKAN database for PostgreSQL"
  type        = string
  default     = "ckan_default"
}

variable "db_datastore_userro" {
  description = "Datapusher user for PostgreSQL"
  type        = string
  default     = "ckan_default"
}

variable "db_datastore_password" {
  description = "Datapusher password for PostgreSQL"
  type        = string
  default     = "ckan_default"
  sensitive   = true
}

variable "db_datastore" {
  description = "Datastore database for PostgreSQL"
  type        = string
  default     = "ckan_default"
}

variable "db_container_name" {
  description = "PostgreSQL host name for CKAN"
  type        = string
  default     = "db"
}

variable "db_container_port" {
  description = "PostgreSQL port for CKAN"
  type        = number
  default     = 5432  
}

variable "ckan_tz" {
  description = "Timezone for the CKAN container"
  type        = string
  default     = "UTC"
}

variable "solr_container_name" {
  description = "Solr host name for CKAN"
  type        = string
  default     = "solr"
}

variable "solr_container_port" {
  description = "Solr port for CKAN"
  type        = number
  default     = 8800
}

variable "solr_container_version" {
  description = "Solr version for CKAN"
  type        = string
  default     = "2.10-solr9"
}

variable "redis_container_name" {
  description = "Redis host name for CKAN"
  type        = string
  default     = "redis"
}

variable "redis_container_port" {
  description = "Redis port for CKAN"
  type        = number
  default     = 6379
}

variable "redis_container_version" {
  description = "Redis version for CKAN"
  type        = string
  default     = "6"
}

variable "datapusher_container_version" {
  description = "Datapusher version for CKAN"
  type        = string
  default     = "2.10"
}

variable "datapusher_internal_site_url" {
  description = "Internal site URL for Datapusher"
  type        = string
  default     = "http://datapusher:8800"
}

variable "server_site_url" {
  description = "Site URL for Doorce Portal"
  type        = string
  # default     = "doorce-portal"
}

variable "server_site_protocol" {
  description = "Site protocol for Doorce Server"
  type        = string
  default     = "http"
}

variable "service_site_path" {
  description = "Site path for Doorce Server"
  type        = string
  default     = "/ckan"
  nullable   = false
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

variable "ckan_admin_password" {
  description = "Password for the CKAN admin user"
  type        = string
  sensitive   = true
}

variable "ckan_admin_name" {
  description = "CKAN sysadmin name"
  type        = string
  default     = "ckan_admin"
}

