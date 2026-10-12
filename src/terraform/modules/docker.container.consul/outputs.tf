output "url" {
  description = "URL to access the Consul service"
  value       = "${var.service_site_protocol}://${var.service_site_url}"
}

output "credentials" {
  description = "Credentials for accessing the Consul service"
  value = "${var.traefik_auth_credentials_username}:${var.traefik_auth_credentials_password}"
  sensitive = true
}

output "credentials_path" {
  description = "Path in Consul KV store where the credentials are stored"
  value       = "credentials"
}