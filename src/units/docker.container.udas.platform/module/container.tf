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
      UDAS_SERVER_URL = var.udas_server_url
      UDAS_APPREPO_URL = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}/apps/"
      SERVICE_SITE_PATH = var.service_site_path
      # Keycloak variables
      KEYCLOAK_PATH = var.keycloak_server_url
      KEYCLOAK_REALM = var.keycloak_realm
      KEYCLOAK_CLIENT = var.keycloak_client
      KEYCLOAK_REDIRECT = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}/"
      KEYCLOAK_CLIENT_SECRET = var.keycloak_client_secret
    }
    tag = [
      "${var.name}:${var.image_version}",
      "${var.name}:latest",
    ]
  }
  timeouts {
    create = "5000m"
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

  volumes {
    container_path = var.udas_apprepo_shared_volume_path
    volume_name    = var.udas_apprepo_shared_volume_name
    read_only     = true
  }

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
    "max-file" = "6"   # Number of log files to keep
  }

  #env = [
  #  "UDAS_PATH=${var.doorce_server_public_site_url}",
  #  "KEYCLOAK_PATH=https://doorce.iem.pw.edu.pl/keycloak",
  #  "KEYCLOAK_REALM=udas",
  #  "KEYCLOAK_CLIENT=udas-panel",
  #  "KEYCLOAK_REDIRECT=https://doorce.iem.pw.edu.pl/panel/",
  #  "KEYCLOAK_CLIENT_SECRET=bLNY2sty7idcFgGVnk6P8G3vZd9PdoRr",
  #]

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
