output "db_postgres" {
  description = "PostgreSQL database for CKAN"
  value       = var.db_postgres
}

output "db_postgres_user" {
  description = "PostgreSQL user for CKAN"
  value       = var.db_postgres_user
}

output "db_postgres_password" {
  description = "PostgreSQL password for CKAN"
  value       = random_password.db_postgres_password.result
  sensitive = true
}

output "db_ckan" {
  description = "CKAN database"
  value       = var.db_ckan
}

output "db_ckan_user" {
  description = "CKAN database user"
  value       = var.db_ckan_user
}

output "db_ckan_password" {
  description = "CKAN database password"
  value       = random_password.db_ckan_password.result
  sensitive = true
}

output "db_datastore" {
  description = "Datastore database"
  value       = var.db_datastore
}

output "db_datastore_userro" {
  description = "Datastore read-only user"
  value       = var.db_datastore_userro
}

output "db_datastore_password" {
  description = "Datastore read-only password"
  value       = random_password.db_datastore_password.result
  sensitive = true
}

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