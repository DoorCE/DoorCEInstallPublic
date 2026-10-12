resource "random_password" "terraform_client_id" {
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

resource "random_password" "terraform_client_secret" {
  length           = 128
  special          = false
  numeric          = true
  upper            = true
  lower            = true
  
  min_special    = 0
  min_numeric    = 4
  min_upper      = 3
  min_lower      = 3
}