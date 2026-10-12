output "name" {
  description = "The name of the network"
  value       = docker_network.this.name
}
output "id" {
  description = "The ID of the network"
  value       = docker_network.this.id
}
output "driver" {
  description = "The driver of the network"
  value       = docker_network.this.driver
}
output "internal" {
  description = "Whether the network is internal or not"
  value       = docker_network.this.internal
}