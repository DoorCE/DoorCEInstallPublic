resource "docker_image" "this" {
  name = var.name
  keep_locally = false # Set to true if you want to keep the image locally after the build 
  triggers = {
    dir_hash = sha256(join("", [
      for f in fileset("${path.module}/docker", "**") : filesha256("${path.module}/docker/${f}")
    ]))
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

resource "docker_volume" "ckan_storage" {
  name = "${var.name}.storage"
}

resource "docker_volume" "ckan_pip_cache" {
  name = "${var.name}.pip.cache"
}

resource "docker_volume" "ckan_site_packages" {
  name = "${var.name}.site.packages"
}

resource "docker_container" "this" {
  name  = var.name
  image = docker_image.this.image_id
  restart = "unless-stopped" # Container restart policy

  volumes {
    container_path = var.ckan_storage_path
    volume_name    = docker_volume.ckan_storage.name
    read_only     = false
  }

  volumes {
    container_path = var.ckan_pip_cache_path
    volume_name    = docker_volume.ckan_pip_cache.name
    read_only     = false
  }

  volumes {
    container_path = var.ckan_site_packages_path
    volume_name    = docker_volume.ckan_site_packages.name
    read_only     = false
  }

  log_opts = {
    "max-size" = "10m" # Log rotation size
    "max-file" = "5"   # Number of log files to keep
  }

  dynamic "networks_advanced" {
    for_each = var.networks
    content {
      name = networks_advanced.value
    }
  }

  healthcheck {
    test     = ["CMD", "wget", "-qO", "/dev/null", "http://localhost:5000/api/action/status_show"]
    interval = "1m0s" # Time between health checks
    timeout  = "20s"  # Time to wait for a health check to succeed
    retries  = 3 # Number of retries before considering the container unhealthy
    start_period = "50s" # Time to wait before starting health checks
  }

  env = [
    "CKAN_ADMIN_API_TOKEN_PATH=${local.ckan_admin_api_token_path}",
    "CKAN___SECRET_KEY=${random_password.ckan_secret_key.result}",
    "CKAN___API_TOKEN__JWT__ENCODE__SECRET=string:${random_password.ckan_jwt_secret.result}",
    "CKAN___API_TOKEN__JWT__DECODE__SECRET=string:${random_password.ckan_jwt_secret.result}",

    # Host Ports
    "CKAN_PORT_HOST=${var.internal_port}",
    "NGINX_PORT_HOST=81", #TODO add nginx container 
    "NGINX_SSLPORT_HOST=8443", #TODO add nginx container

    # CKAN databases
    "POSTGRES_USER=${var.db_postgres_user}",
    "POSTGRES_PASSWORD=${var.db_postgres_password}",
    "POSTGRES_DB=${var.db_postgres}",
    "POSTGRES_HOST=${var.db_container_name}",
    "CKAN_DB_USER=${var.db_ckan_user}",
    "CKAN_DB_PASSWORD=${var.db_ckan_password}",
    "CKAN_DB=${var.db_ckan}",
    "DATASTORE_READONLY_USER=${var.db_datastore_userro}",
    "DATASTORE_READONLY_PASSWORD=${var.db_datastore_password}",
    "DATASTORE_DB=${var.db_datastore}",
    "CKAN_SQLALCHEMY_URL=postgresql://${var.db_ckan_user}:${var.db_ckan_password}@${var.db_container_name}/${var.db_ckan}",
    "CKAN_DATASTORE_WRITE_URL=postgresql://${var.db_ckan_user}:${var.db_ckan_password}@${var.db_container_name}/${var.db_datastore}",
    "CKAN_DATASTORE_READ_URL=postgresql://${var.db_datastore_userro}:${var.db_datastore_password}@${var.db_container_name}/${var.db_datastore}",
    
    # Test database connections
    "TEST_CKAN_SQLALCHEMY_URL=postgres://${var.db_ckan_user}:${var.db_ckan_password}@${var.db_container_name}/ckan_test",
    "TEST_CKAN_DATASTORE_WRITE_URL=postgresql://${var.db_ckan_user}:${var.db_ckan_password}@${var.db_container_name}/datastore_test",
    "TEST_CKAN_DATASTORE_READ_URL=postgresql://${var.db_datastore_userro}:${var.db_datastore_password}@${var.db_container_name}/datastore_test",

    # Dev settings
    "USE_HTTPS_FOR_DEV=false",

    # CKAN core
    "CKAN_VERSION=${var.container_version}",
    "CKAN_SITE_ID=default",
    "CKAN_SITE_URL=${var.server_site_protocol}://${var.server_site_url}",
    "CKAN__ROOT_PATH=${var.service_site_path}",

    # See https://docs.ckan.org/en/latest/maintaining/configuration.html#api-token-settings
    "CKAN_SYSADMIN_NAME=${var.ckan_admin_name}",
    "CKAN_SYSADMIN_PASSWORD=${var.ckan_admin_password}",
    "CKAN_SYSADMIN_EMAIL=admin@doorce.net", #TODO
    "CKAN_STORAGE_PATH=${var.ckan_storage_path}",
    "CKAN_SMTP_SERVER=localhost:25", #TODO
    "CKAN_SMTP_STARTTLS=True", #TODO
    "CKAN_SMTP_USER=user", #TODO
    "CKAN_SMTP_PASSWORD=pass", #TODO
    "CKAN_SMTP_MAIL_FROM=ckan@localhost", #TODO
    "CKAN_MAX_UPLOAD_SIZE_MB=100",
    "TZ=${var.ckan_tz}",

    # Solr"
    "SOLR_IMAGE_VERSION=${var.solr_container_version}",
    "CKAN_SOLR_URL=http://${var.solr_container_name}:${var.solr_container_port}/solr/ckan",
    "TEST_CKAN_SOLR_URL=http://${var.solr_container_name}:${var.solr_container_port}/solr/ckan",
    
    # Redis"
    "REDIS_VERSION=${var.redis_container_version}",
    "CKAN_REDIS_URL=redis://${var.redis_container_name}:${var.redis_container_port}/1",
    "TEST_CKAN_REDIS_URL=redis://${var.redis_container_name}:${var.redis_container_port}/1",

    # Datapusher"
    "DATAPUSHER_VERSION=${var.datapusher_container_version}",
    "CKAN_DATAPUSHER_URL=${var.datapusher_internal_site_url}",
    "CKAN_DATAPUSHER__CALLBACK_URL_BASE=http://${var.name}:${var.internal_port}",

    # NGINX"
    "NGINX_PORT=80", #TODO add nginx container
    "NGINX_SSLPORT=443", #TODO add nginx container
    # Extensions
    #"CKAN__PLUGINS=image_view text_view datatables_view datastore datapusher envvars",
    # "CKAN___CKAN__PLUGINS=fluent scheming_datasets dcat image_view text_view datatables_view datastore datapusher envvars",
    # "CKAN___CKAN__HARVEST__MQ__TYPE=redis",
    # "CKAN___CKAN__HARVEST__MQ__HOSTNAME=${var.redis_container_name}",
    # "CKAN___CKAN__HARVEST__MQ__PORT=${var.redis_container_port}",
    # "CKAN___CKAN__HARVEST__MQ__REDIS_DB=1",
  ]

  # ============================================================================
  # TRAEFIK CONFIGURATION FOR CKAN
  # ============================================================================

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.services.${var.name}.loadbalancer.server.port"
    value = "${var.internal_port}"
  }

  # --- 1. DEFINICJE WSPÓŁDZIELONYCH MIDDLEWARES ---

  # Usuwanie prefiksu /ckan przed przekazaniem zapytania do backendu
  labels {
    label = "traefik.http.middlewares.${var.service_site_path}-stripper.stripprefix.prefixes"
    value = var.service_site_path
  }

  # Przekierowanie fallback 302 (nieuprawnione IP -> strona główna CKAN)
  labels {
    label = "traefik.http.middlewares.${var.name}-redirect-to-portal.redirectregex.regex"
    value = "^.*$"
  }
  labels {
    label = "traefik.http.middlewares.${var.name}-redirect-to-portal.redirectregex.replacement"
    value = "${var.server_site_protocol}://${var.server_site_url}${var.service_site_path}"
  }
  labels {
    label = "traefik.http.middlewares.${var.name}-redirect-to-portal.redirectregex.permanent"
    value = "false"
  }

  # Blokada przestarzałych API (dostęp tylko z pętli zwrotnej)
  labels {
    label = "traefik.http.middlewares.${var.name}-block-legacy.ipallowlist.sourcerange"
    value = "127.0.0.1/32"
  }

  # Ochrona przed przeciążeniem bazy PostgreSQL (np. zrzuty Datastore)
  labels {
    label = "traefik.http.middlewares.${var.name}-ratelimit.ratelimit.average"
    value = "10"
  }
  labels {
    label = "traefik.http.middlewares.${var.name}-ratelimit.ratelimit.period"
    value = "1m"
  }

  # --- 2. ROUTER: BLOKADA LEGACY API (Priorytet 400) ---
  # Całkowicie ucina ruch do starych wersji API v1, v2 oraz narzędzi legacy
  labels {
    label = "traefik.http.routers.${var.name}-legacy.rule"
    value = "Host(`${var.server_site_url}`) && (PathPrefix(`${var.service_site_path}/api/1`) || PathPrefix(`${var.service_site_path}/api/2`) || PathPrefix(`${var.service_site_path}/api/util`))"
  }
  labels {
    label = "traefik.http.routers.${var.name}-legacy.priority"
    value = "400"
  }
  labels {
    label = "traefik.http.routers.${var.name}-legacy.entrypoints"
    value = var.server_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}-legacy.tls"
    value = var.server_site_protocol == "https" ? "true" : "false"
  }
  labels {
    label = "traefik.http.routers.${var.name}-legacy.middlewares"
    value = "${var.name}-block-legacy"
  }

  # --- 3. ROUTER: ŚCIEŻKI KRYTYCZNE DLA ZAUFANYCH IP (Priorytet 300) ---
  # Panel admina oraz rejestracja otwarte TYLKO dla adresów z var.ip_white_list
  labels {
    label = "traefik.http.routers.${var.name}-restricted.rule"
    value = "Host(`${var.server_site_url}`) && (PathPrefix(`${var.service_site_path}/ckan-admin`) || PathPrefix(`${var.service_site_path}/user/register`)) && (${join(" || ", [for ip in var.ip_white_list : "ClientIP(`${ip}`)"])})"
  }
  labels {
    label = "traefik.http.routers.${var.name}-restricted.priority"
    value = "300"
  }
  labels {
    label = "traefik.http.routers.${var.name}-restricted.entrypoints"
    value = var.server_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}-restricted.tls"
    value = var.server_site_protocol == "https" ? "true" : "false"
  }
  labels {
    label = "traefik.http.routers.${var.name}-restricted.middlewares"
    value = "${var.service_site_path}-stripper"
  }

  # --- 4. ROUTER: FALLBACK DLA ŚCIEŻEK KRYTYCZNYCH (Priorytet 290) ---
  # Niezaufane IP próbujące wejść na /ckan-admin lub /user/register są przekierowywane na /ckan
  labels {
    label = "traefik.http.routers.${var.name}-restricted-fallback.rule"
    value = "Host(`${var.server_site_url}`) && (PathPrefix(`${var.service_site_path}/ckan-admin`) || PathPrefix(`${var.service_site_path}/user/register`))"
  }
  labels {
    label = "traefik.http.routers.${var.name}-restricted-fallback.priority"
    value = "290"
  }
  labels {
    label = "traefik.http.routers.${var.name}-restricted-fallback.entrypoints"
    value = var.server_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}-restricted-fallback.tls"
    value = var.server_site_protocol == "https" ? "true" : "false"
  }
  labels {
    label = "traefik.http.routers.${var.name}-restricted-fallback.middlewares"
    value = "${var.name}-redirect-to-portal"
  }

  # --- 5. ROUTER: ENDPOINTY WYMAGAJĄCE RATE-LIMITINGU (Priorytet 200) ---
  # Zabezpieczenie zrzutów Datastore przed atakami wyczerpania zasobów bazy danych
  labels {
    label = "traefik.http.routers.${var.name}-heavy.rule"
    value = "Host(`${var.server_site_url}`) && (PathPrefix(`${var.service_site_path}/datastore/dump`) || PathPrefix(`${var.service_site_path}/api/3/action/datastore_search_sql`))"
  }
  labels {
    label = "traefik.http.routers.${var.name}-heavy.priority"
    value = "200"
  }
  labels {
    label = "traefik.http.routers.${var.name}-heavy.entrypoints"
    value = var.server_site_protocol == "https" ? "websecure" : "web"
  }
  labels {
    label = "traefik.http.routers.${var.name}-heavy.tls"
    value = var.server_site_protocol == "https" ? "true" : "false"
  }
  labels {
    label = "traefik.http.routers.${var.name}-heavy.middlewares"
    value = "${var.name}-ratelimit,${var.service_site_path}-stripper"
  }

  # --- 6. ROUTER: GŁÓWNY RUCH PUBLICZNY (Priorytet 100) ---
  # Standardowy dostęp do zbiorów danych, wyszukiwarki i otwartych widoków
  labels {
    label = "traefik.http.routers.${var.name}.rule"
    value = "Host(`${var.server_site_url}`) && PathPrefix(`${var.service_site_path}`)"
  }
  labels {
    label = "traefik.http.routers.${var.name}.priority"
    value = "100"
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
    label = "traefik.http.routers.${var.name}.middlewares"
    value = "${var.service_site_path}-stripper"
  }

}
