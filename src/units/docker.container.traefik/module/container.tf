resource "docker_image" "this" {
  name = var.name
  keep_locally = false # Set to true if you want to keep the image locally after the build 
  triggers = {
    dockerfile_hash = sha256(file("${path.module}/docker/Dockerfile"))
    # config_hash = sha256(file("${path.module}/docker/traefik.yml"))
    # dynamic_config_hash = sha256(file("${path.module}/docker/dynamic_conf.yml"))
    boot_hash = sha256(file("${path.module}/docker/boot.sh"))
  }
  build {
    context    = "${path.module}/docker"
    dockerfile = "Dockerfile"
    platform = var.container_platform
    build_args = {
      # Add any build arguments here if needed
      CONTAINER_IMAGE   = var.container_image
      CONTAINER_VERSION = var.container_version
    }
    tag = [
      "${var.name}:${var.container_version}",
      "${var.name}:latest",
    ]
  }
}

resource "docker_container" "this" {
  name         = var.name
  image        = docker_image.this.image_id
  restart      = "unless-stopped"
  
  # Traefik korzysta bezpośrednio ze stosu sieciowego maszyny wirtualnej
  network_mode = "host"

  # --- USUNIĘTO: bloki ports dla portu 80 i 443 ---
  # --- USUNIĘTO: networks_advanced { name = var.network_public } ---

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  log_opts = {
    "max-size" = "10m"
    "max-file" = "5"
  }

  env = [
    "HTTPS_KEY=${base64gzip(var.https_key)}",
    "HTTPS_CERT=${base64gzip(var.https_cert)}",
    "TRAEFIK_DYNAMIC_CONF=${base64gzip(var.traefik_dynamic_conf)}",
    "TRAEFIK_STATIC_CONF=${base64gzip(var.traefik_static_conf)}",
    "TRAEFIK_DASHBOARD_USERNAME=${random_password.username.result}",
    "TRAEFIK_DASHBOARD_PASSWORD=${random_password.password.result}"
  ]

  healthcheck {
    test         = ["CMD-SHELL", "curl -s http://localhost:8080/ping | grep -qxF 'OK'"]
    interval     = "1m0s"
    timeout      = "20s"
    retries      = 3
    start_period = "50s"
  }

  # --- LABELS (pozostają bez zmian) ---
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.${var.name}.rule"
    value = "Host(`${var.server_site_url}`) && PathPrefix(`${var.service_site_path}`)"
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
    label = "traefik.http.routers.${var.name}.service"
    value = "api@internal"
  }
  labels {
    label = "traefik.http.middlewares.${var.name}-dashboard-auth.basicauth.users"
    value = "${random_password.username.result}:${htpasswd_password.hash.apr1}"
  }
  labels {
    label = "traefik.http.routers.${var.name}.middlewares"
    value = "${var.name}-dashboard-auth"
  }
  labels {
    label = "traefik.http.services.${var.name}.loadbalancer.server.port"
    value = "${var.internal_dashboard_port}" # czyli 8080
  }
}