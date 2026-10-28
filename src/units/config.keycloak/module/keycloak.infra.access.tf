resource "keycloak_realm" "infra" {
  realm                       = "infra"
  enabled                     = true
  display_name                = "Infrastructure Management"
  default_signature_algorithm = "RS256"
}

# --- KLIENT DOZZLE (OIDC) ---

resource "random_password" "dozzle_client_secret" {
  length  = 64
  special = false
}

resource "keycloak_openid_client" "dozzle" {
  realm_id      = keycloak_realm.infra.id
  client_id     = "dozzle"
  name          = "Dozzle Log Viewer"
  enabled       = true
  access_type   = "CONFIDENTIAL"
  client_secret = random_password.dozzle_client_secret.result

  standard_flow_enabled = true

  # Adresy dozwolone przy logowaniu
  valid_redirect_uris = [
    "${var.service_site_protocol}://${var.service_site_url}${var.dozzle_site_path}/api/auth/callback",
    "${var.service_site_protocol}://${var.service_site_url}${var.dozzle_site_path}/*"
  ]

  # Adresy dozwolone po wylogowaniu (Dozzle przekierowuje na /login)
  valid_post_logout_redirect_uris = [
    "${var.service_site_protocol}://${var.service_site_url}${var.dozzle_site_path}/login",
    "${var.service_site_protocol}://${var.service_site_url}${var.dozzle_site_path}/*",
    "+"
  ]

  web_origins = [
    "${var.service_site_protocol}://${var.service_site_url}"
  ]
}

resource "keycloak_openid_client_default_scopes" "dozzle_scopes" {
  realm_id  = keycloak_realm.infra.id
  client_id = keycloak_openid_client.dozzle.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins"
  ]
}

# Mapowanie ról klienta do pola "roles" w ID Tokenie oraz UserInfo dla Dozzle
resource "keycloak_openid_user_client_role_protocol_mapper" "dozzle_roles" {
  realm_id                    = keycloak_realm.infra.id
  client_id                   = keycloak_openid_client.dozzle.id
  name                        = "dozzle-roles-mapper"
  claim_name                  = "roles"
  client_id_for_role_mappings = "dozzle"
  multivalued                 = true
  add_to_id_token             = true
  add_to_userinfo             = true
  add_to_access_token         = true
}

# --- ROLE I UPRAWNIENIA DOZZLE ---

resource "keycloak_role" "dozzle_all" {
  realm_id    = keycloak_realm.infra.id
  client_id   = keycloak_openid_client.dozzle.id
  name        = "all"
  description = "Pełny dostęp administracyjny do Dozzle"
}

resource "keycloak_role" "dozzle_viewer" {
  realm_id    = keycloak_realm.infra.id
  client_id   = keycloak_openid_client.dozzle.id
  name        = "viewer"
  description = "Dostęp tylko do odczytu (podgląd logów)"
}

resource "keycloak_role" "dozzle_actions" {
  realm_id    = keycloak_realm.infra.id
  client_id   = keycloak_openid_client.dozzle.id
  name        = "actions"
  description = "Pozwala zarządzać stanem kontenerów"
}

resource "keycloak_role" "dozzle_shell" {
  realm_id    = keycloak_realm.infra.id
  client_id   = keycloak_openid_client.dozzle.id
  name        = "shell"
  description = "Odblokowuje dostęp do konsoli/terminala wewnątrz kontenerów"
}

resource "keycloak_role" "dozzle_download" {
  realm_id    = keycloak_realm.infra.id
  client_id   = keycloak_openid_client.dozzle.id
  name        = "download"
  description = "Pozwala użytkownikowi pobierać pełne pliki z logami na dysk lokalny"
}

resource "keycloak_role" "dozzle_notifications" {
  realm_id    = keycloak_realm.infra.id
  client_id   = keycloak_openid_client.dozzle.id
  name        = "notifications"
  description = "Pozwala zarządzać i odbierać powiadomienia oraz alerty"
}

resource "keycloak_role" "dozzle_cloud" {
  realm_id    = keycloak_realm.infra.id
  client_id   = keycloak_openid_client.dozzle.id
  name        = "cloud"
  description = "Odblokowuje funkcje integracji z Dozzle Cloud"
}

resource "keycloak_group" "dozzle_admins" {
  realm_id = keycloak_realm.infra.id
  name     = "dozzle-admins"
}

resource "keycloak_group_roles" "dozzle_admin_roles" {
  realm_id = keycloak_realm.infra.id
  group_id = keycloak_group.dozzle_admins.id
  role_ids = [
    keycloak_role.dozzle_all.id
  ]
}

resource "keycloak_group" "dozzle_viewers" {
  realm_id = keycloak_realm.infra.id
  name     = "dozzle-viewers"
}

resource "keycloak_group_roles" "dozzle_viewer_roles" {
  realm_id = keycloak_realm.infra.id
  group_id = keycloak_group.dozzle_viewers.id
  role_ids = [
    keycloak_role.dozzle_viewer.id
  ]
}

# --- UŻYTKOWNICY ---

resource "random_password" "log_admin_password" {
  length  = 32
  special = true
}

resource "keycloak_user" "log_admin" {
  realm_id       = keycloak_realm.infra.id
  username       = "log-admin"
  enabled        = true
  email          = "log-admin@doorce.net"
  email_verified = true
  first_name     = "Log"
  last_name      = "Admin"

  initial_password {
    value     = random_password.log_admin_password.result
    temporary = false
  }
}

resource "keycloak_user_groups" "admin_membership" {
  realm_id  = keycloak_realm.infra.id
  user_id   = keycloak_user.log_admin.id
  group_ids = [
    keycloak_group.dozzle_admins.id
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
  first_name     = "Log"
  last_name      = "Viewer"

  initial_password {
    value     = random_password.log_viewer_password.result
    temporary = false
  }
}

resource "keycloak_user_groups" "viewer_membership" {
  realm_id  = keycloak_realm.infra.id
  user_id   = keycloak_user.log_viewer.id
  group_ids = [
    keycloak_group.dozzle_viewers.id
  ]
}

# --- PRZYWRÓCONY KLIENT CKAN ADMIN ---

resource "keycloak_openid_client" "ckan_admin_password" {
  realm_id                 = keycloak_realm.infra.id
  client_id                = "ckan-admin-password"
  enabled                  = true
  access_type              = "CONFIDENTIAL"
  service_accounts_enabled = false
  use_refresh_tokens       = true
  standard_flow_enabled    = true
  valid_redirect_uris = [
    "http://localhost:8080/callback"
  ]
}