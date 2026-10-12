terraform {
  source = "./module"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "udas_server" {
  config_path = find_in_parent_folders(values.dependencies.container_udas_server)
  mock_outputs = {
    public_site_url = "http://udas-server/udas"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "udas_platform" {
  config_path = find_in_parent_folders(values.dependencies.container_udas_platform)
  mock_outputs = {
    public_url = "http://udas-url/platform"
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

dependency "network" {
  config_path = find_in_parent_folders(values.dependencies.network)
  mock_outputs = {
    name = "network"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "config_keycloak" {
  config_path = find_in_parent_folders(values.dependencies.config_keycloak)
  mock_outputs = {
    keycloak_client_panel_secret = "mock-client-panel-secret"
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

  keycloak_realm = try(values.keycloak_realm, null)
  keycloak_client = try(values.keycloak_client, null)
  keycloak_client_secret = dependency.config_keycloak.outputs.keycloak_client_panel_secret
  keycloak_server_url = dependency.keycloak.outputs.public_site_url
  
  udas_server_public_site_url = dependency.udas_server.outputs.public_site_url
  udas_platform_public_url = "${dependency.udas_platform.outputs.public_url}/"

  networks = [
    dependency.network.outputs.name,
  ]
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
}
