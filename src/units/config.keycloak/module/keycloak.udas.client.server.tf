resource "random_password" "keycloak_udas_server_password" {
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

resource "keycloak_openid_client" "udas_server" {
  realm_id = keycloak_realm.udas.id
  client_id = "udas-server"
  enabled                 = true
  access_type             = "CONFIDENTIAL"
  service_accounts_enabled = true
  use_refresh_tokens       = false
  client_secret           = random_password.keycloak_udas_server_password.result
  standard_flow_enabled  = true
  valid_redirect_uris    = [
    "/*",
  ]
  web_origins = [
    "/*",
  ]
}

data "keycloak_openid_client" "udas_realm_management" {
  realm_id  = keycloak_realm.udas.id
  client_id = "realm-management"
}

# data "keycloak_role" "udas_view_users" {
#   realm_id  = keycloak_realm.udas.id
#   client_id = data.keycloak_openid_client.udas_realm_management.id
#   name      = "view-users"
# }

# resource "keycloak_openid_client_service_account_role" "udas_server_view_users" {
#   realm_id                = keycloak_realm.udas.id
#   service_account_user_id = keycloak_openid_client.udas_server.service_account_user_id
#   client_id               = data.keycloak_openid_client.udas_realm_management.id
#   role                    = data.keycloak_role.udas_view_users.name
# }


data "keycloak_role" "udas_manage_users" {
  realm_id  = keycloak_realm.udas.id
  client_id = data.keycloak_openid_client.udas_realm_management.id
  name      = "manage-users"
}

resource "keycloak_openid_client_service_account_role" "udas_server_manage_users" {
  realm_id                = keycloak_realm.udas.id
  service_account_user_id = keycloak_openid_client.udas_server.service_account_user_id
  client_id               = data.keycloak_openid_client.udas_realm_management.id
  role                    = data.keycloak_role.udas_manage_users.name
}
