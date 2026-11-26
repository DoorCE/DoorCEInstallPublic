locals {
  public_site_url     = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}"
  terraform_client_id = "terraform-${random_password.terraform_client_id.result}"

  keycloak_terraform_client = {
    "enabled" = true
    "realm"   = "master"
    "clients" = [
      {
        "clientAuthenticatorType"   = "client-secret"
        "clientId"                  = local.terraform_client_id
        "directAccessGrantsEnabled" = false
        "enabled"                   = true
        "fullScopeAllowed"          = true
        "protocol"                  = "openid-connect"
        "publicClient"              = false
        "secret"                    = random_password.terraform_client_secret.result
        "serviceAccountsEnabled"    = true
        "standardFlowEnabled"       = false
        "attributes" = {
          "realm_client"                               = "false"
          "client.use.lightweight.access.token.enabled" = "true"
        }
        "defaultClientScopes" = [
          "web-origins",
          "service_account",
          "acr",
          "kc-admin-api",
          "profile",
          "roles",
          "basic",
          "email"
        ]
      },
    ]
    "users" = [
      {
        "emailVerified"          = true
        "enabled"                = true
        "realmRoles"             = ["admin", "create-realm"]
        "serviceAccountClientId" = local.terraform_client_id
        "username"               = lower("service-account-${local.terraform_client_id}")
      },
    ]
  }
}