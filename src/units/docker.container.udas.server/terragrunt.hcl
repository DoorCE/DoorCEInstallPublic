terraform {
  source = "./module"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "udas-db" {
  config_path = find_in_parent_folders(values.dependencies.container_udas_db)
  mock_outputs = {
    db_udas_server = "db"
    db_udas_port = 5432
    db_udas_database = "__mock__"
    db_udas_username = "__mock__"
    db_udas_password = "__mock__"
    network_for_clients = "__mock_network__name__"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "udas-appgen" {
  config_path = find_in_parent_folders(values.dependencies.container_udas_appgen)
  mock_outputs = {
    internal_url = "http://__mock__:8080/api/"
    network_for_clients = "__mock_network__name__"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "udas-appcmp" {
  config_path = find_in_parent_folders(values.dependencies.container_udas_appcmp)
  mock_outputs = {
    internal_url = "http://__mock__:8080/api/"
    network_for_clients = "__mock_network__name__"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ckan-base" {
  config_path = find_in_parent_folders(values.dependencies.container_ckan_base)
  mock_outputs = {
    internal_site_api_url = "http://udas-ckan-base:5000/api/3/action/"
    ckan_token = "mock-token"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "keycloak" {
  config_path = find_in_parent_folders(values.dependencies.container_keycloak)
  mock_outputs = {
    public_site_url = "https://__change_me__/keycloak/"
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

dependency "config-keycloak" {
  config_path = find_in_parent_folders(values.dependencies.config_keycloak)
  mock_outputs = {
    keycloak_client_panel_secret = "mock-client-panel-secret"
    keycloak_client_server_secret = "mock-client-server-secret"
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

inputs = {
  name = values.name
  image_name = try(values.image_name, null)
  image_version = try(values.image_version, null)
  server_site_protocol = values.server_site_protocol
  server_site_url = values.server_site_url
  service_site_path = try(values.service_site_path, null)
  udas_environment = try(values.udas_environment, null)
  udas_debug = try(values.udas_debug, null)
  udas_demo = try(values.udas_demo, null)
  udas_admin_name = try(values.udas_admin_name, null)

  ckan_authorization_token = dependency.ckan-base.outputs.ckan_token
  ckan_internal_site_url = dependency.ckan-base.outputs.internal_site_api_url
  networks = [
    dependency.udas-db.outputs.network_for_clients,
    dependency.network-public.outputs.name,
    dependency.udas-appgen.outputs.network_for_clients,
    dependency.udas-appcmp.outputs.network_for_clients,
  ]
  db_udas_server = dependency.udas-db.outputs.db_udas_server
  db_udas_port = dependency.udas-db.outputs.db_udas_port
  db_udas_database = dependency.udas-db.outputs.db_udas_database
  db_udas_username = dependency.udas-db.outputs.db_udas_username
  db_udas_password = dependency.udas-db.outputs.db_udas_password

  keycloak_auth_server_url = dependency.keycloak.outputs.public_site_url
  keycloak_realm = try(values.keycloak_realm, null)
  keycloak_resource = try(values.keycloak_resource, null)
  keycloak_server_resource = try(values.keycloak_server_resource, null)
  keycloak_client_secret = dependency.config-keycloak.outputs.keycloak_client_panel_secret
  keycloak_server_client_secret = dependency.config-keycloak.outputs.keycloak_client_server_secret

  udas_appgen_url = dependency.udas-appgen.outputs.internal_url
  udas_appcmp_url = dependency.udas-appcmp.outputs.internal_url

  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
}
