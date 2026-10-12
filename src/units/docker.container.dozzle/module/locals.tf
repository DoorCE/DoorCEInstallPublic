locals {
  credentials = "${var.traefik_auth_credentials_username}:${htpasswd_password.hash.apr1}"
}