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

  # ============================================================================
  # TRAEFIK LABELS FOR DOORCE PORTAL (GRAV CMS)
  # ============================================================================

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.services.${var.name}.loadbalancer.server.port"
    value = "${var.internal_port}"
  }

  # --- 1. DEFINICJE MIDDLEWARES ---

  # Przekierowanie fallback 302 na stronę główną
  labels {
    label = "traefik.http.middlewares.${var.name}-redirect-to-root.redirectregex.regex"
    value = "^.*$"
  }
  labels {
    label = "traefik.http.middlewares.${var.name}-redirect-to-root.redirectregex.replacement"
    value = "${var.server_site_protocol}://${var.server_site_url}/"
  }
  labels {
    label = "traefik.http.middlewares.${var.name}-redirect-to-root.redirectregex.permanent"
    value = "false"
  }

  # Blokada krytycznych zasobów flat-file (dostęp tylko z pętli zwrotnej)
  labels {
    label = "traefik.http.middlewares.${var.name}-block-system.ipallowlist.sourcerange"
    value = "127.0.0.1/32"
  }

  # --- 2. ROUTER: CAŁKOWITA BLOKADA ŚCIEŻEK SYSTEMOWYCH GRAV (Priorytet 400) ---
  # Uniemożliwia pobranie baz YAML, kont użytkowników i kopii zapasowych
  labels {
    label = "traefik.http.routers.${var.name}-system-block.rule"
    value = "Host(`${var.server_site_url}`) && (PathPrefix(`/user/accounts`) || PathPrefix(`/user/config`) || PathPrefix(`/backup`) || PathPrefix(`/bin`))"
  }
  labels {
    label = "traefik.http.routers.${var.name}-system-block.priority"
    value = "400"
  }
  labels {
    label = "traefik.http.routers.${var.name}-system-block.entrypoints"
    value = var.server_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}-system-block.tls"
    value = var.server_site_protocol == "https" ? "true" : "false"
  }
  labels {
    label = "traefik.http.routers.${var.name}-system-block.middlewares"
    value = "${var.name}-block-system"
  }

  # --- 3. ROUTER: PANEL ADMINA DLA ZAUFANYCH IP (Priorytet 200) ---
  # Dozwolone adresy IP wchodzą bezpośrednio do /admin
  labels {
    label = "traefik.http.routers.${var.name}-admin.rule"
    value = "Host(`${var.server_site_url}`) && PathPrefix(`/admin`) && (${join(" || ", [for ip in var.ip_white_list : "ClientIP(`${ip}`)"])})"
  }
  labels {
    label = "traefik.http.routers.${var.name}-admin.priority"
    value = "200"
  }
  labels {
    label = "traefik.http.routers.${var.name}-admin.entrypoints"
    value = var.server_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}-admin.tls"
    value = var.server_site_protocol == "https" ? "true" : "false"
  }

  # --- 4. ROUTER: FALLBACK DLA ADMINA (Priorytet 190) ---
  # Nieuprawnione IP próbujące wejść na /admin zostają odesłane na stronę główną /
  labels {
    label = "traefik.http.routers.${var.name}-admin-fallback.rule"
    value = "Host(`${var.server_site_url}`) && PathPrefix(`/admin`)"
  }
  labels {
    label = "traefik.http.routers.${var.name}-admin-fallback.priority"
    value = "190"
  }
  labels {
    label = "traefik.http.routers.${var.name}-admin-fallback.entrypoints"
    value = var.server_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}-admin-fallback.tls"
    value = var.server_site_protocol == "https" ? "true" : "false"
  }
  labels {
    label = "traefik.http.routers.${var.name}-admin-fallback.middlewares"
    value = "${var.name}-redirect-to-root"
  }

  # --- 5. ROUTER: GŁÓWNY RUCH PUBLICZNY PORTALU (Priorytet 1) ---
  # Standardowy routing dla odwiedzających portal
  labels {
    label = "traefik.http.routers.${var.name}.rule"
    value = "Host(`${var.server_site_url}`)"
  }
  labels {
    label = "traefik.http.routers.${var.name}.priority"
    value = "1"
  }
  labels {
    label = "traefik.http.routers.${var.name}.entrypoints"
    value = var.server_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}.tls"
    value = var.server_site_protocol == "https" ? "true" : "false"
  }
}
