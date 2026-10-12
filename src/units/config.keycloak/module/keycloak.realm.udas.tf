resource "keycloak_realm" "udas" {
  realm             = var.realm_name_udas
  enabled           = true
  default_signature_algorithm = "RS256"
  display_name      = "UDAS Login"
  display_name_html = <<EOF
<p style = "font-size: xxx-large; text-transform: none">UDAS</p>
<p style = "font-size:large; text-transform: none;">Universal Data Aquisition System</p>
<p style = "font-size: small; text-transform: none;">${var.udas_keycloak_message}</p>
EOF
}