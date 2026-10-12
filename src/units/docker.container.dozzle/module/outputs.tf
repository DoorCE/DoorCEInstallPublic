output "container_name" {
  description = "Container name"
  value       = docker_container.this.name
}

output "container_version" {
  description = "Container version"
  value       = var.container_version
}

output "public_url" {
  description = "URL to access the Dozzle service"
  value       = "${var.service_site_protocol}://${var.service_site_url}${var.service_site_path}"
}
