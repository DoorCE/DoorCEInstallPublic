output "container_port" {
  description = "Container port"
  value       = var.internal_port
}

output "internal_site_api_url" {
  description = "Doorce Server internal site URL"
    value       = "http://${docker_container.this.name}:${var.internal_port}"
}

output "external_site_api_url" {
  description = "Doorce Server external site URL"
    value       = "${var.server_site_protocol}://${var.public_site_url}${var.service_site_path}"
}