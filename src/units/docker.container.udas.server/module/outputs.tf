output "internal_site_url" {
  description = "Doorce Server internal site URL"
    value       = "http://${docker_container.this.name}:${var.internal_port}"
}

output "public_site_url" {
  description = "Doorce Server public site URL"
    value       = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}"
}