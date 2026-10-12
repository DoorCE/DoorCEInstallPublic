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
      IMAGE_NAME   = var.image_name
      IMAGE_VERSION = var.image_version
    }
    tag = [
      "${var.name}:${var.image_version}",
      "${var.name}:latest",
    ]
  }
  timeouts {
    create = "40m"
}
}

resource "docker_container" "this" {
  name  = var.name
  image = docker_image.this.image_id
  restart = "unless-stopped" # Container restart policy

  dynamic "networks_advanced" {
    for_each = var.networks
    content {
      name = networks_advanced.value
    }
  }
  log_opts = {
    "max-size" = "10m" # Log rotation size
    "max-file" = "5"   # Number of log files to keep
  }
  
  
  # # Enable Traefik for this container
  labels {
    label = "traefik.enable"
    value = "true"
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
    label = "traefik.http.routers.${var.name}.rule"
    value = "Host(\"${var.public_site_url}\") && PathPrefix(\"${var.service_site_path}\")"
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
    label = "traefik.http.services.${var.name}.loadbalancer.server.port"
    value = "${var.internal_port}"
  }
  # labels {
  #   label = "traefik.http.middlewares.api-cors-headers.headers.accessControlAllowOriginList"
  #   value = "*" # for production, use specific domains
  # }
  # labels {
  #   label = "traefik.http.middlewares.api-cors-headers.headers.accessControlAllowMethods"
  #   value = "GET,POST,OPTIONS,PUT,DELETE"
  # }
  # labels {
  #   label = "traefik.http.middlewares.api-cors-headers.headers.accessControlAllowHeaders"
  #   value = "Authorization,Content-Type,Accept,Origin"
  # }
  # labels {
  #   label = "traefik.http.middlewares.api-cors-headers.headers.accessControlMaxAge"
  #   value = "1728000"
  # }
  # labels {
  #   label = "traefik.http.routers.${var.name}.middlewares"
  #   value = "api-cors-headers@docker"
  # }  

  env = [
      "UDAS_HOST_URL=${var.udas_server_internal_site_url}",
      "CKAN_API_URL=${var.ckan_base_internal_site_api_url}",
  ]

  # healthcheck {
  #   test     = [
  #     "CMD-SHELL",
  #     "curl -s http://localhost:8080/healthz | jq -r '.results.self.status' | grep -qxF 'Healthy'"
  #   ]
  #   interval = "1m0s" # Time between health checks
  #   timeout  = "20s"  # Time to wait for a health check to succeed
  #   retries  = 3 # Number of retries before considering the container unhealthy
  #   start_period = "50s" # Time to wait before starting health checks
  # }
}
