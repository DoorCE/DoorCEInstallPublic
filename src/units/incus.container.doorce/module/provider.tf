provider "incus" {
  generate_client_certificates = true
  accept_remote_certificate    = true
  default_remote               = var.incus_name

  remote {
    name     = var.incus_name
    address  = var.incus_address
    token    = var.incus_token
  }
}