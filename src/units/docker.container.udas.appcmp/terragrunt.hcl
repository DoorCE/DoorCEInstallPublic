terraform {
  source = "./module"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "incus_container_doorce" {
  config_path = find_in_parent_folders(values.dependencies.incus_container_doorce)
  mock_outputs = {
    ipv4_address = "10.10.0.9"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "network_udas_appcmp" {
  config_path = find_in_parent_folders(values.dependencies.network_udas_appcmp)
  mock_outputs = {
    name = "__mock_network_name__"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "volume_udas_apprepo" {
  config_path = find_in_parent_folders(values.dependencies.volume_udas_apprepo)
  mock_outputs = {
    shared_volume_name = "__mock_shared_volume_name__"
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

dependency "keycloak" {
  config_path = find_in_parent_folders(values.dependencies.container_keycloak)
  mock_outputs = {
    public_site_url = "https://__change_me__/keycloak/"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "config-keycloak" {
  config_path = find_in_parent_folders(values.dependencies.config_keycloak)
  mock_outputs = {
    keycloak_client_panel_secret = "mock-client-panel-secret"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
  ssh_port = try(values.ssh_port, null)
  ssh_user = try(values.ssh_user, null)
  ssh_key_path = try(values.ssh_key_path, null)

  name = values.name
  image_name = try(values.image_name, null)
  image_version = try(values.image_version, null)
  udas_server_url = try(values.udas_server_url, null)
  udas_platform_url = try(values.udas_platform_url, null)
  udas_appgen_url = dependency.udas-appgen.outputs.internal_url
  udas_apprepo_shared_volume_name = dependency.volume_udas_apprepo.outputs.shared_volume_name
  
  keycloak_realm = try(values.keycloak_realm, null)
  keycloak_client = try(values.keycloak_client, null)
  keycloak_client_secret = dependency.config-keycloak.outputs.keycloak_client_panel_secret
  keycloak_server_url = dependency.keycloak.outputs.public_site_url

  network_for_clients = dependency.network_udas_appcmp.outputs.name
  networks = [
    dependency.udas-appgen.outputs.network_for_clients,
  ]

  server_site_protocol = values.server_site_protocol
  server_site_url = values.server_site_url

}
