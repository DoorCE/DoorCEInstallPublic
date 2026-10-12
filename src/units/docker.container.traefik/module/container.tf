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
  name  = var.name
  image = docker_image.this.image_id
  restart = "unless-stopped" # Container restart policy

  ports {
    internal = var.internal_http_port
    external = var.host_http_port
  }

  ports {
    internal = var.internal_https_port
    external = var.host_https_port
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  log_opts = {
    "max-size" = "10m" # Log rotation size
    "max-file" = "5"   # Number of log files to keep
  }

  networks_advanced {
    name = var.network_public
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
    test     = ["CMD-SHELL", "curl -s http://localhost:8080/ping | grep -qxF 'OK'"]
    interval = "1m0s" # Time between health checks
    timeout  = "20s"  # Time to wait for a health check to succeed
    retries  = 3 # Number of retries before considering the container unhealthy
    start_period = "50s" # Time to wait before starting health checks
  }

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
  # labels {
  #   label = "traefik.http.middlewares.${var.name}-fail2ban.plugin.fail2ban.rules.statusCodes"
  #   value = "401"
  # }
  # labels {
  #   label = "traefik.http.middlewares.${var.name}-fail2ban.plugin.fail2ban.rules.bantime"
  #   value = "15m"
  # }
  # labels {
  #   label = "traefik.http.middlewares.${var.name}-fail2ban.plugin.fail2ban.rules.findtime"
  #   value = "2m"
  # }
  # labels {
  #   label = "traefik.http.middlewares.${var.name}-fail2ban.plugin.fail2ban.rules.maxretry"
  #   value = "3"
  # }
  # labels {
  #   label = "traefik.http.middlewares.${var.name}-fail2ban.plugin.fail2ban.rules.enabled"
  #   value = "true"
  # }
  # labels {
  #   label = "traefik.http.middlewares.${var.name}-fail2ban.plugin.fail2ban.rules.loglevel"
  #   value = "INFO"
  # }
  labels {
    label = "traefik.http.routers.${var.name}.middlewares"
    #value = "${var.name}-dashboard-auth,${var.name}-fail2ban"
    value = "${var.name}-dashboard-auth"
  }

}
