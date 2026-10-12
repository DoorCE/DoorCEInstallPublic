resource "random_password" "keycloak_udas_panel_password" {
  length           = 128
  special          = false
  numeric          = true
  upper            = true
  lower            = true
  
  min_special    = 0
  min_numeric    = 4
  min_upper      = 3
  min_lower      = 3
}

resource "keycloak_openid_client" "udas_panel" {
  realm_id = keycloak_realm.udas.id
  client_id = "udas-panel"
  enabled                 = true
  access_type             = "CONFIDENTIAL"
  service_accounts_enabled = false
  use_refresh_tokens       = true
  client_secret           = random_password.keycloak_udas_panel_password.result
  standard_flow_enabled  = true
  valid_redirect_uris    = [
    "*",
  ]
  web_origins = [
    "*",
  ]
}
