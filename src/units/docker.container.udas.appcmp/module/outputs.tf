output "internal_url" {
  description = "URL for internal communication between containers"
  value       = local.internal_url
}

output "network_for_clients" {
  description = "Network to which clients will connect to access the service provided by this container"
  value       = var.network_for_clients
}