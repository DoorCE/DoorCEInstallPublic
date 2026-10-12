locals {
  demo_users = var.udas_demo ? {
    "anowak"    = { name = "Anna", surname = "Nowak" }
    "asimon" = { name = "Alex",  surname = "Simon" }
  } : {}

}

resource "keycloak_user" "demo_users" {
  for_each   = local.demo_users
  realm_id   = keycloak_realm.udas.id
  username   = each.key
  enabled    = true
  email      = "${each.key}@doorce.net"
  email_verified = true
  first_name = each.value.name
  last_name  = each.value.surname

  initial_password {
    value     = each.key
    temporary = false
  }

}