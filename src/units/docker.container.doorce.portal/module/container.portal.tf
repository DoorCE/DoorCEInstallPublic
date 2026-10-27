resource "docker_image" "this" {
  name = var.name
  keep_locally = false # Set to true if you want to keep the image locally after the build 
  triggers = {
    dockerfile_hash = sha256(file("${path.module}/docker/Dockerfile"))
  }
  build {
    context    = "${path.module}/docker"
    dockerfile = "Dockerfile"
    platform = var.container_platform
    build_args = {
      # Add any build arguments here if needed
      IMAGE_NAME   = var.image_name,
      IMAGE_VERSION = var.image_version
    }
    tag = [
      "${var.name}:${var.image_version}",
      "${var.name}:latest",
    ]
  }
}

resource "docker_container" "this" {
  lifecycle {
    enabled = var.container_enabled
  }

  name  = var.name
  image = docker_image.this.image_id
  restart = "unless-stopped" # Container restart policy

  env = [
	  # General variables
    "MWARE_URL=${var.middleware_url}",
    "CODE_HELPER_URL=${var.server_site_protocol}://${var.server_site_url}/codehelper/",
  ]

  dynamic "networks_advanced" {
    for_each = var.networks
    content {
      name = networks_advanced.value
    }
  }

  # Enable Traefik for this container
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.${var.name}.priority"
    value = "1" # Set a low priority to ensure it doesn't override more specific routes
  }

  labels {
    label = "traefik.http.routers.${var.name}.rule"
    value = "Host(`${var.server_site_url}`)"
    # value = "Host(`${var.server_site_url}`) && !PathPrefix(`/dozzle`) && !PathPrefix(`/oauth2-proxy`)"
  }

  labels {
    label = "traefik.http.routers.${var.name}.entrypoints"
    value = var.server_site_protocol == "https" ? "websecure" : "web"
  }

  labels {
    label = "traefik.http.routers.${var.name}.tls"
    value = var.server_site_protocol == "https" ? "true" : "false"
  }

  labels {
    label = "traefik.http.services.${var.name}.loadbalancer.server.port"
    value = "${var.internal_port}"
  }

  log_opts = {
    "max-size" = "10m" # Log rotation size
    "max-file" = "5"   # Number of log files to keep
  }

}
