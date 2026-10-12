terraform {
  source = "./module"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "container_doorce_codehelper_backend" {
  config_path = find_in_parent_folders(values.dependencies.container_doorce_codehelper_backend)
  mock_outputs = {
    internal_url = "http://__mock__doorce-codehelper-backend__:8080/api"
    network_for_clients = "network"
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
  doorce_codehelper_backend_internal_url = dependency.container_doorce_codehelper_backend.outputs.internal_url
  networks = [
    dependency.container_doorce_codehelper_backend.outputs.network_for_clients,
  ]
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
}
