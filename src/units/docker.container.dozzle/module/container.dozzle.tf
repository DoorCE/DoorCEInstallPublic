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
  name  = var.name
  image = docker_image.this.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = var.network
  }

  env = [
    "DOZZLE_BASE=${var.service_site_path}",
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

  # --- TRAEFIK LABELS ---

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.${var.name}.rule"
    value = "Host(`${var.service_site_url}`) && PathPrefix(`${var.service_site_path}`)"
  }

  labels {
    label = "traefik.http.routers.${var.name}.priority"
    value = "100" # set a higher priority to ensure this router is matched before more generic ones
  }

  labels {
    label = "traefik.http.routers.${var.name}.entrypoints"
    value = var.service_site_protocol == "https" ? "websecure" : "web"
  }

  labels {
    label = "traefik.http.routers.${var.name}.tls"
    value = var.service_site_protocol == "https" ? "true" : "false"
  }


  # Middleware Auth Forward
  labels {
    label = "traefik.http.middlewares.${var.name}-infra-auth.forwardauth.address"
    value = "http://oauth2-proxy-dozzle:4180/oauth2-proxy/auth"
  }

  labels {
    label = "traefik.http.middlewares.${var.name}-infra-auth.forwardauth.trustForwardHeader"
    value = "true"
  }

  labels {
    label = "traefik.http.middlewares.${var.name}-infra-auth.forwardauth.authResponseHeaders"
    #value = "X-Auth-Request-User,X-Auth-Request-Email,X-Auth-Request-Access-Token,Authorization,Set-Cookie"
    value = "X-Auth-Request-User,X-Auth-Request-Email,Authorization,Set-Cookie"
  }

  labels {
    label = "traefik.http.middlewares.${var.name}-infra-auth.forwardauth.authRequestHeaders"
    value = "X-Forwarded-Method,X-Forwarded-Proto,X-Forwarded-Host,X-Forwarded-Uri,X-Forwarded-For,Cookie"
  }


  # # Middleware Redirect Plugin
  # labels {
  #   label = "traefik.http.middlewares.${var.name}-dozzle-error-redirect.plugin.redirectErrors.status"
  #   value = "401"
  # }

  # labels {
  #   label = "traefik.http.middlewares.${var.name}-dozzle-error-redirect.plugin.redirectErrors.target"
  #   value = "https://${var.service_site_url}/oauth2-proxy/start?rd={url}"
  # }

  # labels {
  #   label = "traefik.http.middlewares.${var.name}-dozzle-error-redirect.plugin.redirectErrors.outputStatus"
  #   value = "302"
  # }

  labels {
    label = "traefik.http.middlewares.${var.name}-error-pages.errors.status"
    value = "401"
  }
  
  labels {
    label = "traefik.http.middlewares.${var.name}-error-pages.errors.service"
    value = "dozzle-oauth2-proxy@docker"
  }
  
  labels {
    label = "traefik.http.middlewares.${var.name}-error-pages.errors.query"
    value = "/oauth2-proxy/start?rd={url}"
  }

  # Chan middleware to handle authentication and error redirection
  labels {
    label = "traefik.http.routers.${var.name}.middlewares"
    #value = "${var.name}-dozzle-error-redirect@docker,${var.name}-infra-auth@docker"
    #value = "${var.name}-infra-auth@docker"
    value = "${var.name}-error-pages@docker,${var.name}-infra-auth@docker"
  }

  labels {
    label = "traefik.http.services.${var.name}.loadbalancer.server.port"
    value = "${var.internal_port}"
  }

  # # Configure Traefik to flush the response immediately, which is important for real-time log streaming in Dozzle
  # labels {
  #   label = "traefik.http.services.${var.name}.loadbalancer.responseForwarding.flushInterval"
  #   value = "1ms" # immediately flush the response to the client for real-time log streaming
  # }
  
}
