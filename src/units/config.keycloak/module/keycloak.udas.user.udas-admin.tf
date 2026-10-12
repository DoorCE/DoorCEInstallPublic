resource "random_password" "udas_admin_password" {
  length           = 32
  special          = false
  numeric          = true
  upper            = true
  lower            = true
  
  min_special    = 0
  min_numeric    = 4
  min_upper      = 3
  min_lower      = 3
}

resource "keycloak_user" "udas_admin" {
  realm_id   = keycloak_realm.udas.id
  username   = var.udas_admin_name
  enabled    = true
  email      = "${var.udas_admin_name}@doorce.net"
  email_verified = true
  first_name = "Udas"
  last_name  = "Admin"

  initial_password {
    value     = random_password.udas_admin_password.result
    temporary = false
  }
}

