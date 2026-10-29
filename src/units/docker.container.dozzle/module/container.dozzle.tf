resource "docker_image" "this" {
  name = var.name
  keep_locally = false 
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

resource "docker_container" "this" {
  name    = var.name
  image   = docker_image.this.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  env = [
    # Bazowa ścieżka URL (np. /dozzle)
    "DOZZLE_BASE=${var.service_site_path}",
    # Metryki
    "DOZZLE_ENABLE_HOST_METRICS=true",
    # Włączenie akcji na kontenerach (restart, start, stop)
    "DOZZLE_ENABLE_ACTIONS=true",
    "DOZZLE_IMAGE_CHECK_MODE=off",   # Wyłącza akcję aktualizacji
    # Konfiguracja natywnego OIDC Dozzle 11
    "DOZZLE_AUTH_PROVIDER=oidc",
    "DOZZLE_AUTH_OIDC_ISSUER=${var.service_site_protocol}://${var.service_site_url}/keycloak/realms/infra",
    "DOZZLE_AUTH_OIDC_CLIENT_ID=dozzle",
    "DOZZLE_AUTH_OIDC_CLIENT_SECRET=${var.dozzle_client_secret}",
    "DOZZLE_AUTH_TTL=1h",
  ]

  log_opts = {
    "max-size" = "10m"
    "max-file" = "5"
  }

  security_opts = [
    "no-new-privileges:true"
  ]

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  volumes {
    host_path      = "${path.cwd}/data/dozzle"
    container_path = "/data"
  }

  # --- TRAEFIK LABELS ---
  labels {
    label = "traefik.enable"
    value = "true"
  }

  # --- 1. ROUTER GŁÓWNY (Dozzle - dostęp tylko dla zaufanych IP) ---
  labels {
    label = "traefik.http.routers.${var.name}.rule"
    value = "Host(`${var.service_site_url}`) && PathPrefix(`${var.service_site_path}`) && (${join(" || ", [for ip in var.ip_white_list : "ClientIP(`${ip}`)"])})"
  }
  labels {
    label = "traefik.http.routers.${var.name}.priority"
    value = "200"
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
    value = "${var.internal_port}"
  }

  # --- 2. ROUTER FALLBACK (Dla pozostałych IP – przekierowanie) ---
  labels {
    label = "traefik.http.routers.${var.name}-fallback.rule"
    value = "Host(`${var.service_site_url}`) && PathPrefix(`${var.service_site_path}`)"
  }
  labels {
    label = "traefik.http.routers.${var.name}-fallback.priority"
    value = "100"
  }
  labels {
    label = "traefik.http.routers.${var.name}-fallback.entrypoints"
    value = var.service_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}-fallback.tls"
    # Zmień z var.server_site_protocol na:
    value = var.service_site_protocol == "https" ? "true" : "false"
  }
  labels {
    label = "traefik.http.routers.${var.name}-fallback.middlewares"
    value = "${var.name}-redirect-to-root"
  }

  # --- 3. MIDDLEWARE PRZEKIEROWANIA (302 Redirect na stronę główną) ---
  labels {
    label = "traefik.http.middlewares.${var.name}-redirect-to-root.redirectregex.regex"
    value = "^.*$"
  }
  labels {
    label = "traefik.http.middlewares.${var.name}-redirect-to-root.redirectregex.replacement"
    value = "${var.service_site_protocol}://${var.service_site_url}/"
  }
  labels {
    label = "traefik.http.middlewares.${var.name}-redirect-to-root.redirectregex.permanent"
    value = "false"
  }

}