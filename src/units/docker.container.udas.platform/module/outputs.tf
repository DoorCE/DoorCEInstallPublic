output "public_url" {
  description = "Public URL for UDAS panel"
  value       = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}"
}