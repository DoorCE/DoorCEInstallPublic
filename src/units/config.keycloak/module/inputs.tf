variable "public_site_url" {
  description = "Keycloak site URL"
  type        = string
}

variable "client_id" {
  description = "Keycloak client ID"
  type        = string
  sensitive = true
}

variable "client_secret" {
  description = "Keycloak client secret"
  type        = string
  sensitive   = true
}

variable "realm_id" {
  description = "Keycloak realm ID"
  type        = string
}

variable "admin_email" {
  description = "Email for the Keycloak admin user"
  type        = string
  default     = "someone@from.berdyczow"
}

variable "admin_email_verified" {
  description = "Whether the Keycloak admin user's email is verified"
  type        = bool
  default     = true
}

variable "admin_first_name" {
  description = "First name for the Keycloak admin user"
  type        = string
  default     = "Admin"
}

variable "admin_last_name" {
  description = "Last name for the Keycloak admin user"
  type        = string
  default     = "Admin"
}

variable "admin_enabled" {
  description = "Whether the Keycloak admin user is enabled"
  type        = bool
  default     = true
}

variable "udas_admin_name" {
  description = "Username for the Keycloak udas-admin user"
  type        = string
  default     = "udas-admin"
}

variable "realm_name_udas" {
  description = "Name of the Keycloak UDAS realm"
  type        = string
  default     = "udas"
}

variable "service_site_protocol" {
  description = "Protocol for the service site URL (e.g., http or https)"
  type        = string
}

variable "service_site_url" {
  description = "Site URL for the service"
  type        = string
}

variable "oauth2_proxy_site_path" {
  description = "Site path for the OAuth2 Proxy service"
  type        = string
  nullable   = false
}

variable "keycloak_admin_username" {
  description = "Username for the Keycloak admin user"
  type        = string
  default     = "infra-admin"
}

variable "keycloak_admin_password" {
  description = "Password for the Keycloak admin user"
  type        = string
  sensitive   = true
}

variable "udas_demo" {
  description = "Demo mode for UDAS Server"
  type        = bool
  default     = false
  nullable   = false
}

variable "udas_keycloak_message" {
  description = "Message for the Keycloak UDAS realm"
  type        = string
  default     = ""
  nullable   = false
}
