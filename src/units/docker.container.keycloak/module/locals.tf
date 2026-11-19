locals {
  public_site_url     = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}"
  terraform_client_id = "terraform-${random_password.terraform_client_id.result}"

  keycloak_terraform_client = {
    "clients" = [
      {
        "clientAuthenticatorType"   = "client-secret"
        "clientId"                  = local.terraform_client_id
        "directAccessGrantsEnabled" = false
        "enabled"                   = true
        "fullScopeAllowed"          = false
        "protocol"                  = "openid-connect"
        "publicClient"              = false
        "secret"                    = random_password.terraform_client_secret.result
        "serviceAccountsEnabled"    = true
        "standardFlowEnabled"       = false
        "defaultClientScopes" = [
          "web-origins",
          "acr",
          "profile",
          "roles",
          "basic",
          "email"
        ]
        "protocolMappers" = [
          {
            "name"            = "admin-api-audience"
            "protocol"        = "openid-connect"
            "protocolMapper"  = "oidc-audience-mapper"
            "consentRequired" = false
            "config" = {
              "included.client.audience" = "master-realm"
              "id.token.claim"           = "false"
              "access.token.claim"       = "true"
            }
          }
        ]
      },
    ]
    "scopeMappings" = [
      {
        "client" = local.terraform_client_id
        "roles"  = ["admin"]
      }
    ]
    "enabled" = true
    "realm"   = "master"
    "users" = [
      {
        "emailVerified"          = true
        "enabled"                = true
        "realmRoles"             = ["admin"]
        "serviceAccountClientId" = local.terraform_client_id
        "username"               = lower("service-account-${local.terraform_client_id}")
      },
    ]
  }
}