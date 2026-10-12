output "internal_url" {
  description = "Internal URL of the service provided by the appgen container"
  value       = local.internal_url
}

output "network_for_clients" {
  description = "Network to which clients (e.g., Traefik) will connect to access the service provided by this container"
  value       = var.network_for_clients
}