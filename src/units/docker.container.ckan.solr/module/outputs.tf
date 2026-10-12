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