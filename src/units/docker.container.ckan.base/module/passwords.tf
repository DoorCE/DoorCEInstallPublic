resource "random_password" "ckan_secret_key" {
  length  = 32
  special = false
}

resource "random_password" "ckan_jwt_secret" {
  length  = 64
  special = false
}