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

dependency "network_udas_appgen" {
  config_path = find_in_parent_folders(values.dependencies.network_udas_appgen)
  mock_outputs = {
    name = "__mock_network_name__"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "udas-db" {
  config_path = find_in_parent_folders(values.dependencies.container_udas_db)
  mock_outputs = {
    db_udas_server = "db"
    db_udas_port = 5432
    db_udas_database = "default"
    db_udas_username = "default"
    db_udas_password = "default"
    network_for_clients = "__mock_network_name__"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  name = values.name
  image_name = try(values.image_name, null)
  image_version = try(values.image_version, null)
  db_udas_server = dependency.udas-db.outputs.db_udas_server
  db_udas_port = dependency.udas-db.outputs.db_udas_port
  db_udas_database = dependency.udas-db.outputs.db_udas_database
  db_udas_username = dependency.udas-db.outputs.db_udas_username
  db_udas_password = dependency.udas-db.outputs.db_udas_password
  udas_environment = try(values.udas_environment, null)
  udas_debug = try(values.udas_debug, null)
  network_for_clients = dependency.network_udas_appgen.outputs.name
  networks = [
    dependency.udas-db.outputs.network_for_clients,
  ]
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
  ssh_port = try(values.ssh_port, null)
  ssh_user = try(values.ssh_user, null)
  ssh_key_path = try(values.ssh_key_path, null)
}
