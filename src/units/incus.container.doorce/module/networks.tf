resource "incus_network_acl" "members-networks-acl" {
  for_each = local.networks
  name        = each.key
  description = "ACL for network ${each.key}"
  egress = [
    {
        action           = "allow"
        state            = "enabled"
        protocol         = "udp"
        destination      = each.value.gateway
        destination_port = "67"
        description      = "Allow DHCP"
    },
    {
        action           = "allow"
        state            = "enabled"
        protocol         = "tcp"
        destination      = each.value.gateway
        destination_port = "53"
        description      = "Allow DNS (TCP)"
    },   
    {
        action           = "allow"
        state            = "enabled"
        protocol         = "udp"
        destination      = each.value.gateway
        destination_port = "53"
        description      = "Allow DNS (UDP)"
    },
    {
        action      = "allow"
        state       = "enabled"
        protocol    = "icmp4"
        description = "Allow Ping/ICMPv4"
    },
    {
        action           = "allow"
        state            = "enabled"
        protocol         = "tcp"
        destination_port = "80,443"
        description      = "Allow HTTP(S) access - Internet"
    },
  ]
  ingress = [
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "tcp"
      source           = "172.16.16.0/28,${each.value.gateway}/32"
      destination_port = "22"
      description      = "Allow SSH from GitHub Runner network"
    },
    {
      action           = "allow"
      state            = "enabled"
      protocol         = "tcp"
      destination_port = "80,443"
      description      = "Allow public HTTP/HTTPS traffic to Traefik"
    },
  ]
}

resource "incus_network" "members-networks" {
  for_each = local.network_members_flat
  name        = each.value.net_name
  target      = each.value.host
}

resource "incus_network" "networks" {
  for_each = local.networks
  depends_on = [
    incus_network_acl.members-networks-acl,
    incus_network.members-networks,
  ]
  name        = each.key
  description = each.value.description
  type        = each.value.type

  config = {
    "ipv4.address"                         = "${each.value.gateway}/${each.value.netmask_short}"
    "ipv4.nat"                             = "true"
    "ipv6.address"                         = "none"
    "security.acls"                        = incus_network_acl.members-networks-acl[each.key].name
    "security.acls.default.egress.action"  = "reject"
    "security.acls.default.ingress.action" = "reject"
  }
}