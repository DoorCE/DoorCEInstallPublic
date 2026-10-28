# resource "docker_image" "this" {
#   name = var.name
#   keep_locally = false # Set to true if you want to keep the image locally after the build 
#   triggers = {
#     dockerfile_hash = sha256(file("${path.module}/docker/Dockerfile"))
#   }
#   build {
#     context    = "${path.module}/docker"
#     dockerfile = "Dockerfile"
#     platform = var.container_platform
#     build_args = {
#       # Add any build arguments here if needed
#       CONTAINER_IMAGE   = var.container_image
#       CONTAINER_VERSION = var.container_version
#     }
#     tag = [
#       "${var.name}:${var.container_version}",
#       "${var.name}:latest",
#     ]
#   }
# }

locals {
  services = [
    "dozzle",
  ]
}

resource "random_password" "cookie_secret" {
  for_each = toset(local.services)
  length = 32
  override_special = "-_"
}

# resource "docker_container" "oauth2_proxy" {
#   for_each = toset(local.services)
#   name  = "${var.name}-${each.key}"
#   image = "${var.container_image}:${var.container_version}"
#   restart = "unless-stopped"

#   networks_advanced {
#     name = var.network
#   }

#   command = [
#     "--reverse-proxy=true",
#     "--trusted-proxy-ip=172.16.0.0/12",
#     "--trusted-proxy-ip=192.168.0.0/16",
#     "--trusted-proxy-ip=10.0.0.0/8"
#   ]

# env = [
#     #OIDC
#     "OAUTH2_PROXY_PROVIDER=keycloak-oidc",
#     "OAUTH2_PROXY_CLIENT_ID=${var.keycloak_client_id}",
#     "OAUTH2_PROXY_CLIENT_SECRET=${var.keycloak_client_secret}",
#     "OAUTH2_PROXY_OIDC_ISSUER_URL=https://${var.service_site_url}/keycloak/realms/${var.keycloak_realm}",
#     "OAUTH2_PROXY_HTTP_ADDRESS=0.0.0.0:${var.internal_port}",
#     "OAUTH2_PROXY_PROXY_PREFIX=/oauth2-proxy", 
#     "OAUTH2_PROXY_ALLOWED_GROUPS=${each.key}",

#     # Cookie settings
#     "OAUTH2_PROXY_WHITELIST_DOMAINS=${var.service_site_url}",
#     "OAUTH2_PROXY_COOKIE_DOMAINS=${var.service_site_url}",
#     "OAUTH2_PROXY_COOKIE_SECRET=${random_password.cookie_secret[each.key].result}",
#     "OAUTH2_PROXY_COOKIE_SECURE=true", # set to true - send cookie only over HTTPS
#     "OAUTH2_PROXY_COOKIE_HTTPONLY=true", # prevent JavaScript access to the cookie
#     "OAUTH2_PROXY_COOKIE_SAMESITE=lax", # prevent CSRF while allowing normal navigation (adjust to "strict" if you want even tighter security)

#     # ForwardAuth settings
#     "OAUTH2_PROXY_SET_XAUTHREQUEST=true", # Set the X-Auth-Request-User and X-Auth-Request-Email headers for the backend
#     "OAUTH2_PROXY_REVERSE_PROXY=true", # Inform the proxy that it's behind another reverse proxy (Traefik) so it can handle headers correctly
#     "OAUTH2_PROXY_UPSTREAM=static://202", # Return 202 Accepted for authenticated requests (Traefik will then forward to the actual backend)

#     # Other settings
#     "OAUTH2_PROXY_SKIP_PROVIDER_BUTTON=true",
#     "OAUTH2_PROXY_REDIRECT_URL=https://${var.service_site_url}/oauth2-proxy/callback",
#     "OAUTH2_PROXY_EMAIL_DOMAINS=*",

#     # "OAUTH2_PROXY_COOKIE_REFRESH=1h",      # refresh the cookie every hour to keep the session alive
#     # "OAUTH2_PROXY_AUTH_RESPONSE_DELAY=0s", # reduce delay after authentication to improve user experience
#   ]

#   labels {
#     label = "traefik.enable"
#     value = "true"
#   }

#   labels {
#     label = "traefik.http.services.${each.key}-oauth2-proxy.loadbalancer.server.port"
#     value = "${var.internal_port}"
#   }

#   labels {
#     label = "traefik.http.routers.${each.key}-oauth2-proxy.rule"
#     value = "Host(`${var.service_site_url}`) && PathPrefix(`/oauth2-proxy`)"
#   }

#   labels {
#     label = "traefik.http.routers.${each.key}-oauth2-proxy.priority"
#     value = "100" 
#   }

#   labels {
#     label = "traefik.http.routers.${each.key}-oauth2-proxy.entrypoints"
#     value = var.service_site_protocol == "https" ? "websecure" : "web"
#   }

#   labels {
#     label = "traefik.http.routers.${each.key}-oauth2-proxy.tls"
#     value = var.service_site_protocol == "https" ? "true" : "false"
#   }
# }