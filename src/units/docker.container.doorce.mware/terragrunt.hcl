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
    internal_site_url = "http://__mock__:8080"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ckan_base" {
  config_path = find_in_parent_folders(values.dependencies.container_ckan_base)
  mock_outputs = {
    internal_site_api_url = "http://__mock__:5000"
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

dependency "incus_container_doorce" {
  config_path = find_in_parent_folders(values.dependencies.incus_container_doorce)
  mock_outputs = {
    ipv4_address = "10.10.0.9"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  name = values.name
  image_version = try(values.image_version, null)
  service_site_path = try(values.service_site_path, null)
  server_site_protocol = values.server_site_protocol
  public_site_url = values.server_site_url
  networks = [
    dependency.network.outputs.name,
  ]
  udas_server_internal_site_url = dependency.udas_server.outputs.internal_site_url
  ckan_base_internal_site_api_url = dependency.ckan_base.outputs.internal_site_api_url
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
}
