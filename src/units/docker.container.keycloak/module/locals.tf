locals {
    public_site_url = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}/"
    terraform_client_id = "terraform-${random_password.terraform_client_id.result}"
    keycloak_terraform_client = {
    "clients" = [
        {
        "clientAuthenticatorType" = "client-secret"
        "clientId" = local.terraform_client_id
        "directAccessGrantsEnabled" = false
        "enabled" = true
        "fullScopeAllowed" = true
        "protocol" = "openid-connect"
        "publicClient" = false
        "secret" = random_password.terraform_client_secret.result
        "serviceAccountsEnabled" = true
        "standardFlowEnabled" = false
        },
    ]
    "enabled" = true
    "realm" = "master"
    "users" = [
        {
        "emailVerified" = true
        "enabled" = true
        "realmRoles" = [
            "admin",
        ]
        "serviceAccountClientId" = local.terraform_client_id
        "username" = "service-account-${local.terraform_client_id}"
        },
    ]
    }
}
