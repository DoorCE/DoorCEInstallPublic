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

resource "docker_container" "this" {
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

  env = [
    "DB_SERVER=${var.db_udas_server}",
    "DB_PORT=${var.db_udas_port}",
    "DB_DATABASE=${var.db_udas_database}",
    "DB_USERNAME=${var.db_udas_username}",
    "DB_PASSWORD=${var.db_udas_password}",
    "ASPNETCORE_URLS=${local.internal_url}",
    "ASPNETCORE_ENVIRONMENT=${var.udas_environment}",
    "Debug=${var.udas_debug}",
    #"APP_PORT=${var.service_port}",
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
