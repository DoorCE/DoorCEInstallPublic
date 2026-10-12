output "internal_site_url" {
  value       = "${var.service_protocol}://${var.name}:${var.internal_port}/"
  description = "Internal URL for the Datapusher service"
}
