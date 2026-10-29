terraform {
  source = "./module"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "network-solr" {
  config_path = find_in_parent_folders(values.dependencies.network_ckan_solr)
  mock_outputs = {
    name = "network"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "network-redis" {
  config_path = find_in_parent_folders(values.dependencies.network_ckan_redis)
  mock_outputs = {
    name = "network"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "network-db" {
  config_path = find_in_parent_folders(values.dependencies.network_ckan_db)
  mock_outputs = {
    name = "network"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "network-public" {
  config_path = find_in_parent_folders(values.dependencies.network_public)
  mock_outputs = {
    name = "network"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ckan-db" {
  config_path = find_in_parent_folders(values.dependencies.container_ckan_db)
  mock_outputs = {
    container_name = "db"
    container_port = 5432
    db_postgres = "default"
    db_postgres_user = "default"
    db_postgres_password = "default"
    db_ckan = "default"
    db_ckan_user = "default"
    db_ckan_password = "default"
    db_datastore = "default"
    db_datastore_userro = "default"
    db_datastore_password = "default"
  }
}

dependency "ckan-solr" {
  config_path = find_in_parent_folders(values.dependencies.container_ckan_solr)
  mock_outputs = {
    container_name = "solr"
    container_port = 8983
    container_version = "2.10-solr9"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ckan-redis" {
  config_path = find_in_parent_folders(values.dependencies.container_ckan_redis)
  mock_outputs = {
    container_name = "redis"
    container_port = 6379
    container_version = "6"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ckan-datapusher" {
  config_path = find_in_parent_folders(values.dependencies.container_ckan_datapusher)
  mock_outputs = {
    internal_site_url = "http://datapusher:8800"
    container_version = "2.11"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "incus_container_doorce" {
  config_path = find_in_parent_folders(values.dependencies.incus_container_doorce)
  mock_outputs = {
    ipv4_address = "10.10.0.9"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "keycloak" {
  config_path = find_in_parent_folders(values.dependencies.config_keycloak)
  mock_outputs = {
    "ckan_admin_password" = "__mock-ckan-admin-password__"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}


inputs = {
  name = values.name
  container_image = try(values.container_image, null)
  container_version = try(values.container_version, null)
  server_site_protocol = values.server_site_protocol
  server_site_url = values.server_site_url
  service_site_path = try(values.service_site_path, null)
  ip_white_list = values.ip_white_list
  networks = [
    dependency.network-public.outputs.name,
    dependency.network-solr.outputs.name,
    dependency.network-redis.outputs.name,
    dependency.network-db.outputs.name,
  ]
  db_container_name = dependency.ckan-db.outputs.container_name
  db_container_port = dependency.ckan-db.outputs.container_port
  db_postgres = dependency.ckan-db.outputs.db_postgres
  db_postgres_user = dependency.ckan-db.outputs.db_postgres_user
  db_postgres_password = dependency.ckan-db.outputs.db_postgres_password
  db_ckan = dependency.ckan-db.outputs.db_ckan
  db_ckan_user = dependency.ckan-db.outputs.db_ckan_user
  db_ckan_password = dependency.ckan-db.outputs.db_ckan_password
  db_datastore = dependency.ckan-db.outputs.db_datastore
  db_datastore_userro = dependency.ckan-db.outputs.db_datastore_userro
  db_datastore_password = dependency.ckan-db.outputs.db_datastore_password
  solr_container_name = dependency.ckan-solr.outputs.container_name
  solr_container_port = dependency.ckan-solr.outputs.container_port
  solr_container_version = dependency.ckan-solr.outputs.container_version
  redis_container_name = dependency.ckan-redis.outputs.container_name
  redis_container_port = dependency.ckan-redis.outputs.container_port
  redis_container_version = dependency.ckan-redis.outputs.container_version
  datapusher_container_version = dependency.ckan-datapusher.outputs.container_version
  datapusher_internal_site_url = dependency.ckan-datapusher.outputs.internal_site_url
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
  ckan_admin_password = dependency.keycloak.outputs.ckan_admin_password
}
