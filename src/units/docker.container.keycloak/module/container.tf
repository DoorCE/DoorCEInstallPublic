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
    "KC_PROXY_HEADERS=forwarded",
    "KC_HOSTNAME=${local.public_site_url}",
    "KC_HEALTH_ENABLED=true",
    "KC_LOG_LEVEL=INFO",
    "KC_METRICS_ENABLED=true",
    "KC_IMPORT_CONTENT_B64=${base64gzip(jsonencode(local.keycloak_terraform_client))}",
    "KC_BOOTSTRAP_ADMIN_USERNAME=${var.keycloak_admin_username}",
    "KC_BOOTSTRAP_ADMIN_PASSWORD=${var.keycloak_admin_password}",
  ]

  entrypoint = ["/bin/sh", "-c"]
  command = [
    <<-EOT
    echo "$KC_IMPORT_CONTENT_B64" | base64 -d | gzip -d | jq -r > /opt/keycloak/data/import/realm-master.json
    unset KC_IMPORT_CONTENT_B64

    /opt/keycloak/bin/kc.sh bootstrap-admin service --client-id bootstrap-admin --client-secret:env KC_BOOTSTRAP_ADMIN_PASSWORD || true

    /opt/keycloak/bin/kc.sh start --import-realm &
    KC_PID=$!
    trap "kill -TERM $KC_PID 2>/dev/null || true" TERM INT

    until curl -sf http://localhost:9000/health/ready > /dev/null 2>&1; do
      kill -0 $KC_PID 2>/dev/null || exit 1
      sleep 2
    done

    CLIENT_ID=$(jq -r '.clients[0].clientId' /opt/keycloak/data/import/realm-master.json)

    /opt/keycloak/bin/kcadm.sh config credentials \
      --server http://localhost:8080 \
      --realm master \
      --client bootstrap-admin \
      --secret "$KC_BOOTSTRAP_ADMIN_PASSWORD"

    CLIENT_UUID=$(/opt/keycloak/bin/kcadm.sh get clients -r master -q clientId="$CLIENT_ID" --fields id | jq -r '.[0].id')

    /opt/keycloak/bin/kcadm.sh update "clients/$CLIENT_UUID" -r master -s fullScopeAllowed=false

    ROLES_SCOPE_ID=$(/opt/keycloak/bin/kcadm.sh get client-scopes -r master --fields id,name | jq -r '.[] | select(.name=="roles") | .id')
    if [ -n "$ROLES_SCOPE_ID" ]; then
      /opt/keycloak/bin/kcadm.sh update "clients/$CLIENT_UUID/default-client-scopes/$ROLES_SCOPE_ID" -r master || true
    fi

    if ! /opt/keycloak/bin/kcadm.sh get "clients/$CLIENT_UUID/protocol-mappers/models" -r master | grep -q "admin-api-audience"; then
      /opt/keycloak/bin/kcadm.sh create "clients/$CLIENT_UUID/protocol-mappers/models" -r master \
        -s name=admin-api-audience \
        -s protocol=openid-connect \
        -s protocolMapper=oidc-audience-mapper \
        -s consentRequired=false \
        -s 'config."included.client.audience"=master-realm' \
        -s 'config."id.token.claim"=false' \
        -s 'config."access.token.claim"=true'
    fi

    SA_USERNAME=$(echo "service-account-$CLIENT_ID" | tr '[:upper:]' '[:lower:]')
    /opt/keycloak/bin/kcadm.sh add-roles --uusername "$SA_USERNAME" --rolename admin -r master || true
    /opt/keycloak/bin/kcadm.sh add-roles --uusername "$SA_USERNAME" --cclientid master-realm --rolename admin -r master || true

    BOOTSTRAP_UUID=$(/opt/keycloak/bin/kcadm.sh get clients -r master -q clientId=bootstrap-admin --fields id | jq -r '.[0].id')
    if [ -n "$BOOTSTRAP_UUID" ] && [ "$BOOTSTRAP_UUID" != "null" ]; then
      /opt/keycloak/bin/kcadm.sh delete "clients/$BOOTSTRAP_UUID" -r master || true
    fi

    wait $KC_PID
    EOT
  ]

  healthcheck {
    test         = ["CMD-SHELL", "curl -f -s http://localhost:9000/health || exit 1"]
    interval     = "10s"
    timeout      = "5s"
    retries      = 3
    start_period = "1m0s"
  }

  # ============================================================================
  # TRAEFIK LABELS FOR KEYCLOAK
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

  # Usuwanie prefiksu /keycloak przed przekazaniem do kontenera
  labels {
    label = "traefik.http.middlewares.${var.service_site_path}-stripper.stripprefix.prefixes"
    value = var.service_site_path
  }

  # Przekierowanie fallback 302 na stronę główną dla niepowołanych IP
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

  # --- 2. ROUTER: ŚCIEŻKI KRYTYCZNE DLA ZAUFANYCH IP (Priorytet 300) ---
  # Konsola /admin, realm master oraz endpointy diagnostyczne
  labels {
    label = "traefik.http.routers.${var.name}-restricted.rule"
    value = "Host(`${var.server_site_url}`) && (PathPrefix(`${var.service_site_path}/admin`) || PathPrefix(`${var.service_site_path}/realms/master`) || PathPrefix(`${var.service_site_path}/metrics`) || PathPrefix(`${var.service_site_path}/health`)) && (${join(" || ", [for ip in var.ip_white_list : "ClientIP(`${ip}`)"])})"
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
    value = "${var.service_site_path}-stripper@docker"
  }

  # --- 3. ROUTER: FALLBACK DLA ŚCIEŻEK KRYTYCZNYCH (Priorytet 290) ---
  # Przekierowanie nieuprawnionych IP na stronę główną (zamiast pokazywania błędu 403 lub formularza logowania mastera)
  labels {
    label = "traefik.http.routers.${var.name}-restricted-fallback.rule"
    value = "Host(`${var.server_site_url}`) && (PathPrefix(`${var.service_site_path}/admin`) || PathPrefix(`${var.service_site_path}/realms/master`) || PathPrefix(`${var.service_site_path}/metrics`) || PathPrefix(`${var.service_site_path}/health`))"
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
    value = "${var.name}-redirect-to-root@docker"
  }

  # --- 4. ROUTER: GŁÓWNY RUCH OIDC / REALMY APLIKACYJNE (Priorytet 100) ---
  # Pozwala użytkownikom logować się do realmów aplikacji (np. infra), pobierać tokeny i ładować motywy
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
    value = "${var.service_site_path}-stripper@docker"
  }
}
