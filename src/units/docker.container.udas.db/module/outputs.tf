output "db_udas_database" {
  description = "PostgreSQL database for UDAS Server"
  value       = var.db_udas_database
}

output "db_udas_username" {
  description = "PostgreSQL user for UDAS Server"
  value       = var.db_udas_username
}

output "db_udas_password" {
  description = "PostgreSQL password for UDAS Server"
  value       = random_password.db_udas_password.result
  sensitive = true
}

output "db_udas_port" {
  description = "DB server port"
  value       = var.internal_port
}

output "db_udas_server" {
  description = "DB server name"
  value       = docker_container.this.name
}

output "network_for_clients" {
  description = "Network to connect the container to for client access"
  value       = var.network_for_clients
}