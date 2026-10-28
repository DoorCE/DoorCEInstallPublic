locals {
  server_site_protocol = split("://", values.configuration.doorce.external_url)[0]
  server_site_url = split("://", values.configuration.doorce.external_url)[1]
  keycloak_admin_password = get_env("KEYCLOAK_ADMIN_PASSWORD")
  keycloak_admin_username = get_env("KEYCLOAK_ADMIN_USERNAME")
  configuration = values.configuration.zones["zone1"]
  incus_name    = local.configuration.master
  incus_address = "https://${local.configuration.members[local.incus_name].address}:8443"
  incus_token   = trimspace(fileexists("/opt/github-runner/incus/${local.incus_name}_incus_token.txt") ? file("/opt/github-runner/incus/${local.incus_name}_incus_token.txt") : "")
  ssh_public_key  = values.ssh_public_key
  https_key = get_env("TRAEFIK_KEY")
  https_cert = get_env("TRAEFIK_CERT")

  udas_server_site_path = "/udas"
  udas_platform_site_path = "/platform"
  oauth2_proxy_site_path = "/oauth2-proxy"
  dozzle_site_path = "/dozzle"

  unit_path = {
    incus_container_doorce = "incus/csys/doorce"

    network_public = "docker/net/public"
    container_traefik = "docker/capp/traefik"
    container_dozzle = "docker/capp/dozzle"
    container_keycloak = "docker/capp/keycloak"
    config_keycloak = "docker/config/keycloak"
    container_oauth2_proxy = "docker/capp/oauth2-proxy"

    network_ckan_solr = "docker/net/ckan/solr"
    network_ckan_redis = "docker/net/ckan/redis"
    network_ckan_db = "docker/net/ckan/db"
    network_ckan_datapusher = "docker/net/ckan/datapusher"
    container_ckan_datapusher = "docker/capp/ckan/datapusher"
    container_ckan_db = "docker/capp/ckan/db"
    container_ckan_redis = "docker/capp/ckan/redis"
    container_ckan_solr = "docker/capp/ckan/solr"
    container_ckan_base = "docker/capp/ckan/base"
    
    network_udas_db = "docker/net/udas/db"
    volume_udas_apprepo = "docker/vol/udas/apprepo"
    network_udas_appgen = "docker/net/udas/appgen"
    container_udas_appgen = "docker/capp/udas/appgen"
    network_udas_appcmp = "docker/net/udas/appcmp"
    container_udas_appcmp = "docker/capp/udas/appcmp"
    container_udas_db = "docker/capp/udas/db"
    container_udas_server = "docker/capp/udas/server"
    container_udas_panel = "docker/capp/udas/panel"
    container_udas_platform = "docker/capp/udas/platform"

    container_doorce_mware = "docker/capp/doorce/mware"
    container_doorce_portal = "docker/capp/doorce/portal"
    container_doorce_codehelper_backend = "docker/capp/doorce/codehelper/backend"
    container_doorce_codehelper_frontend = "docker/capp/doorce/codehelper/frontend"
  }
}

unit "incus/csys/doorce" {
  source = find_in_parent_folders("src/units/incus.container.doorce")
  path   = local.unit_path.incus_container_doorce
  values = {
    incus_name    = local.incus_name
    incus_address = local.incus_address
    incus_token   = local.incus_token
    ssh_public_key  = local.ssh_public_key
    configuration = local.configuration
  }
}

## networks
unit "docker/net/public" {
  source = find_in_parent_folders("src/units/docker.network")
  path   = local.unit_path.network_public
  values = {
    name   = "public"
    internal = false
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/net/ckan/datapusher" {
  source = find_in_parent_folders("src/units/docker.network")
  path   = local.unit_path.network_ckan_datapusher
  values = {
    name   = "ckan-datapusher"
    internal = true
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/net/ckan/db" {
  source = find_in_parent_folders("src/units/docker.network")
  path   = local.unit_path.network_ckan_db
  values = {
    name   = "ckan-db"
    internal = true
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/net/ckan/redis" {
  source = find_in_parent_folders("src/units/docker.network")
  path   = local.unit_path.network_ckan_redis
  values = {
    name   = "ckan-redis"
    internal = true
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/net/ckan/solr" {
  source = find_in_parent_folders("src/units/docker.network")
  path   = local.unit_path.network_ckan_solr
  values = {
    name   = "ckan-solr"
    internal = true
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/net/udas/db" {
  source = find_in_parent_folders("src/units/docker.network")
  path   = local.unit_path.network_udas_db
  values = {
    name   = "udas-db"
    internal = false
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/net/udas/appgen" {
  source = find_in_parent_folders("src/units/docker.network")
  path   = local.unit_path.network_udas_appgen
  values = {
    name   = "udas-appgen"
    internal = false
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/net/udas/appcmp" {
  source = find_in_parent_folders("src/units/docker.network")
  path   = local.unit_path.network_udas_appcmp
  values = {
    name   = "udas-appcmp"
    internal = false
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

# #### containers

unit "docker/capp/traefik" {
  source = find_in_parent_folders("src/units/docker.container.traefik")
  path   = local.unit_path.container_traefik
  values = {
    name = "traefik"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    service_site_path = "/traefik"
    https_key = local.https_key
    https_cert = local.https_cert
    dependencies = {
      network = local.unit_path.network_public
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/dozzle" {
  source = find_in_parent_folders("src/units/docker.container.dozzle")
  path   = local.unit_path.container_dozzle
  values = {
    name = "dozzle"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    dozzle_site_path = local.dozzle_site_path
    dependencies = {
      network = local.unit_path.network_public
      # traefik = local.unit_path.container_traefik
      incus_container_doorce = local.unit_path.incus_container_doorce
      config_keycloak = local.unit_path.config_keycloak
    }
  }
}

unit "docker/capp/keycloak" {
  source = find_in_parent_folders("src/units/docker.container.keycloak")
  path   = local.unit_path.container_keycloak
  values = {
    name = "keycloak"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    dependencies = {
      network = local.unit_path.network_public
      traefik = local.unit_path.container_traefik
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/config/keycloak" {
  source = find_in_parent_folders("src/units/config.keycloak")
  path   = local.unit_path.config_keycloak
  values = {
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    oauth2_proxy_site_path = local.oauth2_proxy_site_path
    keycloak_admin_username = local.keycloak_admin_username
    keycloak_admin_password = local.keycloak_admin_password
    udas_demo = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_server.demo, null)
    udas_keycloak_message = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_panel.keycloak.message, null)
    dependencies = {
      container_keycloak = local.unit_path.container_keycloak
    }
  }
}

unit "docker/capp/oauth2-proxy" {
  source = find_in_parent_folders("src/units/docker.container.oauth2-proxy")
  path   = local.unit_path.container_oauth2_proxy
  values = {
    name = "oauth2-proxy"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    service_site_path = local.oauth2_proxy_site_path
    dependencies = {
      network = local.unit_path.network_public
      traefik = local.unit_path.container_traefik
      config_keycloak = local.unit_path.config_keycloak
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

#### ckan
unit "docker/capp/ckan/datapusher" {
  source = find_in_parent_folders("src/units/docker.container.ckan.datapusher")
  path   = local.unit_path.container_ckan_datapusher
  values = {
    name = "ckan-datapusher"
    dependencies = {
      network = local.unit_path.network_public
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/ckan/db" {
  source = find_in_parent_folders("src/units/docker.container.ckan.db")
  path   = local.unit_path.container_ckan_db
  values = {
    name = "ckan-db"
    dependencies = {
      network = local.unit_path.network_ckan_db
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/ckan/redis" {
  source = find_in_parent_folders("src/units/docker.container.redis")
  path   = local.unit_path.container_ckan_redis
  values = {
    name = "ckan-redis"
    dependencies = {
      network = local.unit_path.network_ckan_redis
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/ckan/solr" {
  source = find_in_parent_folders("src/units/docker.container.ckan.solr")
  path   = local.unit_path.container_ckan_solr
  values = {
    name = "ckan-solr"
    dependencies = {
      network = local.unit_path.network_ckan_solr
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/ckan/base" {
  source = find_in_parent_folders("src/units/docker.container.ckan.base")
  path   = local.unit_path.container_ckan_base
  values = {
    name = "ckan-base"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    dependencies = {
      network_ckan_solr = local.unit_path.network_ckan_solr
      network_ckan_redis = local.unit_path.network_ckan_redis
      network_ckan_db = local.unit_path.network_ckan_db
      network_public = local.unit_path.network_public
      container_ckan_db = local.unit_path.container_ckan_db
      container_ckan_solr = local.unit_path.container_ckan_solr
      container_ckan_redis = local.unit_path.container_ckan_redis
      container_ckan_datapusher = local.unit_path.container_ckan_datapusher
      incus_container_doorce = local.unit_path.incus_container_doorce
      config_keycloak = local.unit_path.config_keycloak
    }
  }
}

###

unit "docker/capp/udas/db" {
  source = find_in_parent_folders("src/units/docker.container.udas.db")
  path   = local.unit_path.container_udas_db
  values = {
    name = "udas-db"
    dependencies = {
      network_for_clients = local.unit_path.network_udas_db
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/vol/udas/repository" {
  source = find_in_parent_folders("src/units/docker.volume.udas.apprepo")
  path   = "docker/vol/udas-repository"
  values = {
    name = "udas-repository"
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/vol/udas/apprepo" {
  source = find_in_parent_folders("src/units/docker.volume.udas.apprepo")
  path   = local.unit_path.volume_udas_apprepo
  values = {
    name = "udas-apprepo"
    dependencies = {
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/udas/appgen" {
  source = find_in_parent_folders("src/units/docker.container.udas.appgen")
  path   = local.unit_path.container_udas_appgen
  values = {
    name = "udas-appgen"
    image_version = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_appgen.version, null)
    udas_environment = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_appgen.environment, null)
    udas_debug = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_appgen.debug, null)
    dependencies = {
      network_udas_appgen = local.unit_path.network_udas_appgen
      container_udas_db = local.unit_path.container_udas_db
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/udas/appcmp" {
  source = find_in_parent_folders("src/units/docker.container.udas.appcmp")
  path   = local.unit_path.container_udas_appcmp
  values = {
    name = "udas-appcmp"
    image_version = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_appcmp.version, null)
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    udas_server_url = "${local.server_site_protocol}://${local.server_site_url}${local.udas_server_site_path}"
    udas_platform_url = "${local.server_site_protocol}://${local.server_site_url}${local.udas_platform_site_path}"
    dependencies = {
      container_keycloak = local.unit_path.container_keycloak
      config_keycloak = local.unit_path.config_keycloak
      network_udas_appcmp = local.unit_path.network_udas_appcmp
      container_udas_appgen = local.unit_path.container_udas_appgen
      volume_udas_apprepo = local.unit_path.volume_udas_apprepo
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/udas/platform" {
  source = find_in_parent_folders("src/units/docker.container.udas.platform")
  path   = local.unit_path.container_udas_platform
  values = {
    name = "udas-platform"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    server_site_path = local.udas_platform_site_path
    image_version = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_platform.version, null)
    dependencies = {
      container_keycloak = local.unit_path.container_keycloak
      config_keycloak = local.unit_path.config_keycloak
      network_public = local.unit_path.network_public
      container_udas_server = local.unit_path.container_udas_server
      volume_udas_apprepo = local.unit_path.volume_udas_apprepo
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/udas/server" {
  source = find_in_parent_folders("src/units/docker.container.udas.server")
  path   = local.unit_path.container_udas_server
  values = {
    name = "udas-server"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    image_version = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_server.version, null)
    udas_environment = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_server.environment, null)
    udas_debug = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_server.debug, null)
    udas_demo = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_server.demo, null)
    dependencies = {
      container_ckan_base = local.unit_path.container_ckan_base
      container_keycloak = local.unit_path.container_keycloak
      container_udas_db = local.unit_path.container_udas_db
      container_udas_appgen = local.unit_path.container_udas_appgen
      container_udas_appcmp = local.unit_path.container_udas_appcmp
      network_public = local.unit_path.network_public
      config_keycloak = local.unit_path.config_keycloak
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/doorce/mware" {
  source = find_in_parent_folders("src/units/docker.container.doorce.mware")
  path   = local.unit_path.container_doorce_mware
  values = {
    name = "doorce-mware"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    image_version = try(yamldecode(file(find_in_parent_folders("config.yaml"))).doorce_mware.version, null)
    dependencies = {
      container_udas_server = local.unit_path.container_udas_server
      container_ckan_base = local.unit_path.container_ckan_base
      network = local.unit_path.network_public
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/doorce/portal" {
  source = find_in_parent_folders("src/units/docker.container.doorce.portal")
  path   = local.unit_path.container_doorce_portal
  values = {
    name = "doorce-portal"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    image_version = try(yamldecode(file(find_in_parent_folders("config.yaml"))).doorce_portal.version, null)
    container_enabled = try(yamldecode(file(find_in_parent_folders("config.yaml"))).doorce_portal.deploy, null)
    dependencies = {
      network = local.unit_path.network_public
      container_doorce_mware = local.unit_path.container_doorce_mware
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/udas/panel" {
  source = find_in_parent_folders("src/units/docker.container.udas.panel")
  path   = local.unit_path.container_udas_panel
  values = {
    name = "udas-panel"
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    image_version = try(yamldecode(file(find_in_parent_folders("config.yaml"))).udas_panel.version, null)
    dependencies = {
      container_udas_server = local.unit_path.container_udas_server
      container_udas_platform = local.unit_path.container_udas_platform
      container_keycloak = local.unit_path.container_keycloak
      network = local.unit_path.network_public
      config_keycloak = local.unit_path.config_keycloak
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

# ###

unit "docker/capp/doorce/codehelper/backend" {
  source = find_in_parent_folders("src/units/docker.container.doorce.codehelper.backend")
  path   = local.unit_path.container_doorce_codehelper_backend
  values = {
    name = "doorce-codehelper-backend"
    image_version = try(yamldecode(file(find_in_parent_folders("config.yaml"))).doorce_codehelper_backend.version, null)
    dependencies = {
      network_doorce_codehelper = local.unit_path.network_public
      #network_ckan_base = local.unit_path.network_public
      container_ckan_base = local.unit_path.container_ckan_base
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

unit "docker/capp/doorce/codehelper/frontend" {
  source = find_in_parent_folders("src/units/docker.container.doorce.codehelper.frontend")
  path   = local.unit_path.container_doorce_codehelper_frontend
  values = {
    name = "doorce-codehelper-frontend"
    image_version = try(yamldecode(file(find_in_parent_folders("config.yaml"))).doorce_codehelper_frontend.version, null)
    server_site_protocol = local.server_site_protocol
    server_site_url = local.server_site_url
    dependencies = {
      #network_public = local.unit_path.network_public
      container_doorce_codehelper_backend = local.unit_path.container_doorce_codehelper_backend
      incus_container_doorce = local.unit_path.incus_container_doorce
    }
  }
}

