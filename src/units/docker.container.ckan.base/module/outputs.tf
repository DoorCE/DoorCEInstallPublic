output "container_port" {
  description = "Container port"
  value       = var.internal_port
}

output "container_name" {
  description = "Container name"
  value       = docker_container.this.name
}

output "container_version" {
  description = "Container version"
  value       = var.container_version
}

output "internal_url" {
  description = "Internal URL for CKAN container"
  value       = "http://${docker_container.this.name}:${var.internal_port}"
}

output "internal_site_api_url" {
  description = "Internal CKAN API url"
  value       = "http://${docker_container.this.name}:${var.internal_port}/api/3/action"
}

output "ckan_token" {
  description = "CKAN API token"
  value       = data.external.ckan_admin_token.result.token
  sensitive   = true
}

output "ckan_site_url" {
  description = "CKAN site url"
  value       = local.public_site_url
}