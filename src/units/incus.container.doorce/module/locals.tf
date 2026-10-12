locals {
  member_names = keys(var.members)
  networks = {
    for net_name, net_config in var.networks : net_name => {
      name        = net_name
      type        = net_config.type
      description = net_config.description
      network     = cidrsubnet(net_config.address, 0, 0)
      gateway     = cidrhost(cidrsubnet(net_config.address, 0, 0), 1)
      netmask     = cidrnetmask(net_config.address)
      netmask_short = split("/", net_config.address)[1]
      members     = local.member_names
    }
  }
  network_members_flat = merge([
    for net_id, net_data in local.networks : {
      for member in net_data.members : "${net_id}_${member}" => {
        net_name = net_id
        host     = member
        config   = net_data # zachowujemy dostęp do gateway, prefix itp.
      }
    }
  ]...)
}

# output "networks" {
#   value = local.networks
# }

# output "network_members_flat" {
#   value = local.network_members_flat
# }