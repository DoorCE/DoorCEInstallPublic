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
    name = "mock-network"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "traefik" {
  config_path = find_in_parent_folders(values.dependencies.traefik)
  mock_outputs = {
    server_site_protocol = "https"
    server_site_url      = "mock-traefik.local"
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
  container_image = try(values.container_image, null)
  container_version = try(values.container_version, null)
  networks = [
    dependency.network.outputs.name,
  ]
  server_site_protocol = dependency.traefik.outputs.server_site_protocol
  server_site_url = dependency.traefik.outputs.server_site_url
  service_site_path = try(values.service_site_path, null)
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
}
