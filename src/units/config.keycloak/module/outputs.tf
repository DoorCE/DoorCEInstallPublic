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

output "oauth2_proxy_client_id" {
  description = "Keycloak client ID for OAuth2 Proxy"
  value       = keycloak_openid_client.oauth2_proxy.client_id
}

output "oauth2_proxy_client_secret" {
  description = "Keycloak client secret for OAuth2 Proxy"
  value       = keycloak_openid_client.oauth2_proxy.client_secret
  sensitive   = true
}

output "oauth2_proxy_realm" {
  description = "Keycloak realm for OAuth2 Proxy"
  value       = keycloak_realm.infra.realm
}

output "ckan_admin_password" {
  description = "The password for the CKAN admin user"
  value       = keycloak_openid_client.ckan_admin_password.client_secret
  sensitive   = true
}