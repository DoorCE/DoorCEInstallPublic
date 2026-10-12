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
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
}
