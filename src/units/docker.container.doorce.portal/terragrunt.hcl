terraform {
  source = "./module"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "network" {
  config_path = find_in_parent_folders(values.dependencies.network)
  mock_outputs = {
    name = "network"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "doorce-mware" {
  config_path = find_in_parent_folders(values.dependencies.container_doorce_mware)
  mock_outputs = {
    external_site_api_url = "http://__mock__/mware"
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
  server_site_url = values.server_site_url
  middleware_url = dependency.doorce-mware.outputs.external_site_api_url
  networks = [
    dependency.network.outputs.name,
  ]
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
}
