resource "keycloak_realm" "infra" {
  realm             = "infra"
  enabled           = true
  display_name      = "Infrastructure Management"
  default_signature_algorithm = "RS256"
}

resource "random_password" "oauth2_proxy_secret" {
  length  = 64
  special = false
}

resource "keycloak_openid_client" "oauth2_proxy" {
  realm_id      = keycloak_realm.infra.id
  client_id     = "infra-proxy"
  name          = "Infrastructure Proxy"
  enabled       = true
  access_type   = "CONFIDENTIAL"
  client_secret = random_password.oauth2_proxy_secret.result

  standard_flow_enabled = true
  
  valid_redirect_uris = [
    "${var.service_site_protocol}://${var.service_site_url}${var.oauth2_proxy_site_path}/callback"
  ]
  web_origins = [
    "${var.service_site_protocol}://${var.service_site_url}"
  ]
}

resource "keycloak_openid_client_scope" "groups" {
  realm_id               = keycloak_realm.infra.id
  name                   = "groups"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "groups_mapper" {
  realm_id        = keycloak_realm.infra.id
  client_scope_id = keycloak_openid_client_scope.groups.id
  name            = "groups-mapper"

  claim_name = "groups"
  full_path  = false
}


resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
  realm_id  = keycloak_realm.infra.id
  client_id = keycloak_openid_client.oauth2_proxy.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.groups.name,
  ]
}


resource "random_password" "log_viewer_password" {
  length  = 32
  special = true
}

resource "keycloak_user" "log_viewer" {
  realm_id       = keycloak_realm.infra.id
  username       = "log-viewer"
  enabled        = true
  email          = "log-viewer@doorce.net"
  email_verified = true
  first_name = "Infra"
  last_name  = "Admin"

  initial_password {
    value     = random_password.log_viewer_password.result
    temporary = false
  }
  required_actions = [
    "UPDATE_PASSWORD"
  ]
}

# Create a group for dozzle users
resource "keycloak_group" "dozzle_group" {
  realm_id = keycloak_realm.infra.id 
  name     = "dozzle"
}

# Add the log-viewer user to the dozzle group
resource "keycloak_user_groups" "user_dozzle_membership" {
  realm_id   = keycloak_realm.infra.id 
  user_id    = keycloak_user.log_viewer.id 
  group_ids = [
    keycloak_group.dozzle_group.id
  ]
}


resource "keycloak_openid_client" "ckan_admin_password" {
  realm_id = keycloak_realm.infra.id
  client_id = "ckan-admin-password"
  enabled                 = true
  access_type             = "CONFIDENTIAL"
  service_accounts_enabled = false
  use_refresh_tokens       = true
  # client_secret           = random_password.keycloak_udas_panel_password.result
  standard_flow_enabled  = true
  valid_redirect_uris = [
    "http://localhost:8080/callback"
  ]
}