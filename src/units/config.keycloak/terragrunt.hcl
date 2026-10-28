terraform {
  source = "./module"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "keycloak" {
  config_path = find_in_parent_folders(values.dependencies.container_keycloak)
  mock_outputs = {
    public_site_url = "https://mock-keycloak.local"
    client_id       = "mock-client-id"
    client_secret   = "mock-client-secret"
    realm_id        = "master"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  public_site_url = dependency.keycloak.outputs.public_site_url
  client_id       = dependency.keycloak.outputs.client_id
  client_secret   = dependency.keycloak.outputs.client_secret
  realm_id        = dependency.keycloak.outputs.realm_id
  keycloak_admin_username = try(values.keycloak_admin_username, null)
  keycloak_admin_password = try(values.keycloak_admin_password, null)
  service_site_protocol = values.server_site_protocol
  service_site_url = values.server_site_url
  dozzle_site_path = try(values.dozzle_site_path, null)
  udas_demo = try(values.udas_demo, null)
  udas_keycloak_message = try(values.udas_keycloak_message, null)
}
