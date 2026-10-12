resource "docker_image" "this" {
  name = var.name
  keep_locally = false # Set to true if you want to keep the image locally after the build 
  triggers = {
    dockerfile_hash = sha256(file("${path.module}/docker/Dockerfile"))
    dockerfile_hash = sha256(file("${path.module}/docker/consul.json"))
  }
  build {
    context    = "${path.module}/docker"
    dockerfile = "Dockerfile"
    platform = var.container_platform
    build_args = {
      # Add any build arguments here if needed
      CONTAINER_IMAGE   = var.container_image
      CONTAINER_VERSION = var.container_version
      # NETWORK_PROXY     = var.network_name
    }
    tag = [
      "${var.name}:${var.container_version}",
      "${var.name}:latest",
    ]
  }
}

resource "docker_volume" "data" {
  name = "${var.name}.data"
}

resource "docker_container" "this" {
  name  = var.name
  image = docker_image.this.image_id
  restart = "unless-stopped" # Container restart policy

  volumes {
    container_path = var.data_path
    volume_name    = docker_volume.data.name
    read_only     = false
  }

  log_opts = {
    "max-size" = "10m" # Log rotation size
    "max-file" = "5"   # Number of log files to keep
  }

  networks_advanced {
    name = var.network
  }

  command = [
    "agent",
    "-server",
    "-bootstrap-expect=1",
    "-ui",
    "-client=0.0.0.0",
    "-data-dir=/consul/data",
    "-config-file=/consul/config/consul.json",
  ]

  healthcheck {
    test     = ["CMD-SHELL", "consul operator raft list-peers | grep -E 'leader[[:space:]]+true' || exit 1"]
    interval = "1m0s"
    timeout  = "15s"
    retries  = 3
    start_period = "10s" # Time to wait before starting health checks
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.name}.rule"
    value = "Host(`${var.service_site_url}`) && (PathPrefix(`${var.service_site_path}`) || PathPrefix(`/v1`))"
  }
  labels {
    label = "traefik.http.routers.${var.name}.entrypoints"
    value = var.service_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}.tls"
    value = var.service_site_protocol == "https" ? "true" : "false"
  }
  labels {
    label = "traefik.http.services.${var.name}.loadbalancer.server.port"
    value = tostring(var.internal_http_api_port)
  }
  labels {
    label = "traefik.http.middlewares.${var.name}-auth.basicauth.users"
    value = local.credentials
  }
  labels {
    label = "traefik.http.routers.${var.name}.middlewares"
    value = "${var.name}-auth"
  }
}
