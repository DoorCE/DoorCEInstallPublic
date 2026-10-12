terraform {
  source = "./module"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "network" {
  config_path = find_in_parent_folders(values.dependencies.network_for_clients)
  mock_outputs = {
    name = "__mock__network__name__"
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
  network_for_clients = dependency.network.outputs.name
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
  ssh_port = try(values.ssh_port, null)
  ssh_user = try(values.ssh_user, null)
  ssh_key_path = try(values.ssh_key_path, null)
}
