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
  name  = var.name
  image = docker_image.this.image_id
  restart = "unless-stopped" # Container restart policy

  dynamic "networks_advanced" {
    for_each = var.networks
    content {
      name = networks_advanced.value
    }
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
    "max-file" = "5"   # Number of log files to keep
  }

  env = [
    "ASPNETCORE_URLS=http://${var.name}:${var.internal_port}",
    "APP_PORT=${var.internal_port}",
	  # General variables
    "DOORCE_ENVIRONMENT=${var.udas_environment}", # to be removed
    "UDAS_ENVIRONMENT=${var.udas_environment}", # to be removed
    "ASPNETCORE_ENVIRONMENT=${var.udas_environment}",
	  "Debug=${var.udas_debug ? "True" : "False"}",
	  "Demo=${var.udas_demo ? "True" : "False"}",
	  "AdminName=${var.udas_admin_name}",
	  # Database variables
    "DB_SERVER=${var.db_udas_server}",
    "DB_PORT=${var.db_udas_port}",
    "DB_DATABASE=${var.db_udas_database}",
    "DB_USERNAME=${var.db_udas_username}",
    "DB_PASSWORD=${var.db_udas_password}",
	  # CKAN variables
    "CKAN_BASE_ADDRESS=${var.ckan_internal_site_url}",
    "CKAN_AUTHORIZATION_TOKEN=${var.ckan_authorization_token}",
    "UDAS_PATH=${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}", # do usunięcia
    "UDAS_EXTERNAL_URL=${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}",
    # Keycloak variables
    "Keycloak:Realm=${var.keycloak_realm}",
    "Keycloak:AuthServerUrl=${var.keycloak_auth_server_url}",
    "Keycloak:SslRequired=${var.keycloak_ssl_required}",
    "Keycloak:Resource=${var.keycloak_resource}",
	  "Keycloak:ClientSecret=${var.keycloak_client_secret}",
    "Keycloak:PublicClient=${var.keycloak_public_client}",
    "Keycloak:ConfidentialPort=${var.keycloak_confidential_port}",
    "Keycloak:VerifyTokenAudience=${var.keycloak_verify_token_audience}",
    "KeycloakServer:Resource=${var.keycloak_server_resource}",
    "KeycloakServer:ClientSecret=${var.keycloak_server_client_secret}",
    # UDAS App Generator variables
    "UDAS_APPGEN_URL=${var.udas_appgen_url}",
    # UDAS App Compiler variables
    "UDAS_APPCMP_URL=${var.udas_appcmp_url}",
  ]

  healthcheck {
    test     = [
      "CMD-SHELL",
      "curl -s http://localhost:${var.internal_port}/healthz | jq -r '.results.self.status' | grep -qxF 'Healthy'"
    ]
    interval = "1m0s" # Time between health checks
    timeout  = "20s"  # Time to wait for a health check to succeed
    retries  = 3 # Number of retries before considering the container unhealthy
    start_period = "15s" # Time to wait before starting health checks
  }
}
