locals {
    public_site_url = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}/"
    ckan_admin_api_token_path = "${var.ckan_storage_path}/ckan_admin_api_token.txt"
}
