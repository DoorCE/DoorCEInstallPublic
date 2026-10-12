output "public_site_url" {
  description = "URL to access the public site"
  value       = local.public_site_url
}

output "client_id" {
  description = "Keycloak client ID"
  value       = local.terraform_client_id
  sensitive   = true
}

output "client_secret" {
  description = "Keycloak client secret"
  value       = random_password.terraform_client_secret.result
  sensitive   = true
}

output "realm_id" {
  description = "Keycloak realm ID"
  value       = "master"
}
