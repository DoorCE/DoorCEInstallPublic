provider "htpasswd" {
}

resource "random_password" "password" {
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

resource "random_password" "username" {
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


resource "random_password" "salt" {
  length           = 8
  special          = false
  min_special    = 0
  min_numeric    = 2
  min_upper      = 2
  min_lower      = 2
}

resource "htpasswd_password" "hash" {
  password = random_password.password.result
  salt     = random_password.salt.result
}
