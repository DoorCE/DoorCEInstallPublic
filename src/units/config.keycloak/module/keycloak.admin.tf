resource "terraform_data" "admin_password_trigger" {
  input = var.keycloak_admin_password
}

resource "keycloak_user" "keycloak_admin_user" {
  realm_id = var.realm_id
  # all letters in the username must be lowercase, otherwise Keycloak will not create the user and will not return an error, which can be confusing
  username = var.keycloak_admin_username
  email    = var.admin_email
  email_verified = var.admin_email_verified
  first_name = var.admin_first_name
  last_name  = var.admin_last_name
  enabled  = var.admin_enabled
  initial_password {
    value     = var.keycloak_admin_password
    temporary = false # Temporary password, can be set to true if you want the user to change it on first login
  }
  lifecycle {
    replace_triggered_by = [
      terraform_data.admin_password_trigger
    ]
  }
}

data "keycloak_realm" "master" {
  realm = var.realm_id
}

data "keycloak_role" "admin_role" {
  realm_id  = data.keycloak_realm.master.id
  name      = "admin"
}

resource "keycloak_user_roles" "admin_user_roles" {
  realm_id = data.keycloak_realm.master.id
  user_id  = keycloak_user.keycloak_admin_user.id

  # Assign the admin role to the new user
  role_ids = [
    data.keycloak_role.admin_role.id
  ]
}
