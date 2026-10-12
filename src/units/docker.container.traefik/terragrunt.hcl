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
  https_key = values.https_key
  https_cert = values.https_cert
  server_site_protocol = values.server_site_protocol
  server_site_url = values.server_site_url
  service_site_path = try(values.service_site_path, null)
  traefik_dynamic_conf = file("conf/traefik.dynamic.conf.yml")
  traefik_static_conf = templatefile(
    "conf/traefik.yml",
    {
      network = dependency.network.outputs.name
      service_site_path = try(values.service_site_path, null)
    }
  )
  network_public = dependency.network.outputs.name
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
}

