terraform {
  source = "./module"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

inputs = {
  incus_name    = values.incus_name
  incus_address = values.incus_address
  incus_token   = values.incus_token
  ssh_public_key  = values.ssh_public_key
  members = try(values.configuration.members, null)
  networks = try(values.configuration.networks, null)
}
