output "keycloak_client_server_secret" {
  description = "The secret for the Keycloak UDAS client - server"
  value       = keycloak_openid_client.udas_server.client_secret
  sensitive   = true
}

output "keycloak_client_panel_secret" {
  description = "The secret for the Keycloak UDAS client - panel"
  value       = keycloak_openid_client.udas_panel.client_secret
  sensitive   = true
}

output "ckan_admin_password" {
  description = "The password for the CKAN admin user"
  value       = keycloak_openid_client.ckan_admin_password.client_secret
  sensitive   = true
}

output "dozzle_client_secret" {
  value     = random_password.dozzle_client_secret.result
  sensitive = true
}