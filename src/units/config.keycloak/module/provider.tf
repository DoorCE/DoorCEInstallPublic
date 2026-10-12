provider "keycloak" {
  url           = var.public_site_url
  client_id     = var.client_id
  client_secret = var.client_secret
  realm         = var.realm_id
}
