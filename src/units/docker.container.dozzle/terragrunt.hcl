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

# dependency "traefik" {
#   config_path = find_in_parent_folders(values.dependencies.traefik)
#   mock_outputs = {
#     traefik_auth_credentials_username = "mock-username"
#     traefik_auth_credentials_password = "mock-password"
#   }
#   mock_outputs_merge_strategy_with_state = "shallow"
# }

dependency "incus_container_doorce" {
  config_path = find_in_parent_folders(values.dependencies.incus_container_doorce)
  mock_outputs = {
    ipv4_address = "10.10.0.9"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "keycloak" {
  config_path = find_in_parent_folders(values.dependencies.config_keycloak)
  mock_outputs = {
    dozzle_client_secret = "__mock-client-secret__"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  name = values.name
  container_image = try(values.container_image, null)
  container_version = try(values.container_version, null)
  network = dependency.network.outputs.name
  service_site_protocol = values.server_site_protocol
  service_site_url = values.server_site_url
  service_site_path = try(values.service_site_path, null)
  # traefik_auth_credentials_username = dependency.traefik.outputs.traefik_auth_credentials_username
  # traefik_auth_credentials_password = dependency.traefik.outputs.traefik_auth_credentials_password
  ssh_host = dependency.incus_container_doorce.outputs.ipv4_address
  # oauth2_proxy_site_path = try(values.oauth2_proxy_site_path, null)
  dozzle_client_secret = dependency.keycloak.outputs.dozzle_client_secret
}
