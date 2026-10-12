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
      CONTAINER_IMAGE   = var.container_image
      CONTAINER_VERSION = var.container_version
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
  #memory = 2048 # Limit 2GB RAM
  cpu_shares = 512

  dynamic "networks_advanced" {
    for_each = var.networks
    content {
      name = networks_advanced.value
    }
  }

  volumes {
    container_path = var.data_path
    volume_name    = docker_volume.data.name
    read_only     = false
  }


  env = [
    "KC_DB=dev-file",
    "KC_HTTP_ENABLED=true",
    "KC_CACHE=local",
    "KC_PROXY_HEADERS=forwarded", # Use forwarded headers for proxying
    "KC_HOSTNAME=${local.public_site_url}", # Set the hostname for Keycloak
    "KC_HEALTH_ENABLED=true",
    "KC_LOG_LEVEL=INFO",
    "KC_METRICS_ENABLED=true",
    "KC_IMPORT_CONTENT_B64=${base64gzip(jsonencode(local.keycloak_terraform_client))}",
    # "KC_BOOTSTRAP_ADMIN_USERNAME=ad",
    # "KC_BOOTSTRAP_ADMIN_PASSWORD=aa",
  ]

  entrypoint = ["/bin/sh", "-c"]
  command = [
    "echo $KC_IMPORT_CONTENT_B64 | base64 -d | gzip -d | jq -r > /opt/keycloak/data/import/realm-master.json && export KC_IMPORT_CONTENT_B64='' && unset KC_IMPORT_CONTENT_B64 && /opt/keycloak/bin/kc.sh start --import-realm"
  ]

  # Enable Traefik for this container
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.${var.name}.rule"
    value = "Host(\"${var.server_site_url}\") && PathPrefix(\"${var.service_site_path}\")"
  }

  labels {
    label = "traefik.http.routers.${var.name}.middlewares"
    value = "${var.service_site_path}-stripper@docker" # Name of the middleware to use
  }

  labels {
    label = "traefik.http.middlewares.${var.service_site_path}-stripper.stripprefix.prefixes"
    value = var.service_site_path # prefix to strip
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

  healthcheck {
    test         = ["CMD-SHELL", "curl -f -s http://localhost:9000/health || exit 1"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 3
    start_period = "1m0s"
  }
}
