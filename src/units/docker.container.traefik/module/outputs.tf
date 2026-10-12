output "traefik_dashboard_url" {
  description = "URL to access the Traefik dashboard"
  value       = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}/dashboard/"
}

output "traefik_auth_credentials_username" {
  description = "Username for Traefik dashboard basic auth"
  value       = random_password.username.result
  sensitive   = true
}

output "traefik_auth_credentials_password" {
  description = "Password for Traefik dashboard basic auth"
  value       = random_password.password.result
  sensitive   = true
}

output "server_site_protocol" {
  description = "Protocol for the Traefik site"
  value       = var.server_site_protocol
}

output "server_site_url" {
  description = "URL for the Traefik site"
  value       = var.server_site_url
}