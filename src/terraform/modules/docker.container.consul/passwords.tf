provider "htpasswd" {
}

resource "random_password" "salt" {
  length           = 8
  special          = false
  min_special    = 0
  min_numeric    = 2
  min_upper      = 2
  min_lower      = 2
}

resource "htpasswd_password" "hash" {
  password = var.traefik_auth_credentials_password
  salt     = random_password.salt.result
}
