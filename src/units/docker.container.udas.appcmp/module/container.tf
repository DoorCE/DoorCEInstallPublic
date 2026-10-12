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
      CONTAINER_IMAGE   = var.image_name
      CONTAINER_VERSION = var.image_version
    }
    tag = [
      "${var.name}:${var.image_version}",
      "${var.name}:latest",
    ]
  }
}


resource "docker_container" "init_fix_perms" {
  name  = "${var.name}-init-permissions"
  image = "alpine:latest"
  
  command = [
    "sh", "-c", 
    "chown -R 1001:1001 ${var.udas_apprepo_shared_volume_path} && chmod -R 755 ${var.udas_apprepo_shared_volume_path}"
  ]

  volumes {
    container_path = var.udas_apprepo_shared_volume_path
    volume_name    = var.udas_apprepo_shared_volume_name
    read_only      = false
  }
  rm = false
  must_run = false
  lifecycle {
    replace_triggered_by = [docker_image.this.id]
  }
}


resource "docker_container" "this" {
  depends_on = [
    docker_container.init_fix_perms,
  ]

  name  = var.name
  image = docker_image.this.image_id
  restart = "unless-stopped" # Container restart policy
  publish_all_ports = false # We will specify port bindings explicitly

  dynamic "networks_advanced" {
    for_each = concat(var.networks, [var.network_for_clients])
    content {
      name = networks_advanced.value
    }
  }

  volumes {
    container_path = var.udas_apprepo_shared_volume_path
    volume_name    = var.udas_apprepo_shared_volume_name
    read_only     = false
  }

  env = [
    "UDAS_APPGEN_URL=${var.udas_appgen_url}",
    "UDAS_SERVER_URL=${var.udas_server_url}",
    "UDAS_PLATFORM_URL=${var.udas_platform_url}",
    "UDAS_APPREPO_PATH=${var.udas_apprepo_shared_volume_path}",
    "UDAS_APPREPO_URL=${var.server_site_protocol}://${var.server_site_url}/platform/apps/",
    "SERVICE_PORT=${var.service_port}",
      # Keycloak variables
    "KEYCLOAK_PATH=${var.keycloak_server_url}",
    "KEYCLOAK_REALM=${var.keycloak_realm}",
    "KEYCLOAK_CLIENT=${var.keycloak_client}",
    "KEYCLOAK_REDIRECT=${var.udas_platform_url}",
    "KEYCLOAK_CLIENT_SECRET=${var.keycloak_client_secret}",
  ]

  log_opts = {
    "max-size" = "10m" # Log rotation size
    "max-file" = "5"   # Number of log files to keep
  }

  # healthcheck {
  #   test = [
  #     "CMD-SHELL",
  #     "curl -s http://localhost:${var.service_port}/healthz | jq -r '.results.self.status' | grep -qxF 'Healthy'"
  #   ]
    
  #   interval     = "30s"
  #   timeout      = "5s"
  #   retries      = 3
  #   start_period = "15s"
  # }
}
