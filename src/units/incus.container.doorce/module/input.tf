variable "incus_name" {
  type        = string
  description = "Name of the Incus remote to use"
}

variable "incus_address" {
  type        = string
  description = "Address of the Incus remote to use"
}

variable "incus_token" {
  type        = string
  description = "Token for authenticating with the Incus remote"
  sensitive   = true
}

variable  "ssh_public_key" {
  description = "SSH public key to be added to the container for access"
  type        = string
}

variable "members" {
  description = "Map of cluster members with their details" 
  type = map(object({
    address = string
    user    = string
  }))
  nullable = false
}

variable "networks" {
  description = "Map of networks with their details"
  type = map(object({
    address = string
    type    = string
    description = string
  }))
  nullable = false
}
