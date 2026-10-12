resource "random_password" "db_postgres_password" {
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

resource "random_password" "db_ckan_password" {
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

resource "random_password" "db_datastore_password" {
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
