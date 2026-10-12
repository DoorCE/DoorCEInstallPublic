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

  volumes {
    container_path = var.data_path
    volume_name    = docker_volume.data.name
    read_only     = false
  }

  dynamic "networks_advanced" {
    for_each = var.networks
    content {
      name = networks_advanced.value
    }
  }

  env = [
    "POSTGRES_DB=${var.db_postgres}",
    "POSTGRES_USER=${var.db_postgres_user}",
    "POSTGRES_PASSWORD=${random_password.db_postgres_password.result}",
    "CKAN_DB=${var.db_ckan}",
    "CKAN_DB_USER=${var.db_ckan_user}",
    "CKAN_DB_PASSWORD=${random_password.db_ckan_password.result}",
    "DATASTORE_DB=${var.db_datastore}",
    "DATASTORE_READONLY_USER=${var.db_datastore_userro}",
    "DATASTORE_READONLY_PASSWORD=${random_password.db_datastore_password.result}",
  ]

  log_opts = {
    "max-size" = "10m" # Log rotation size
    "max-file" = "5"   # Number of log files to keep
  }


  healthcheck {
    test     = ["CMD", "pg_isready", "-U", "${var.db_postgres_user}", "-d", "${var.db_postgres}"]
    interval = "1m0s" # Time between health checks
    timeout  = "20s"  # Time to wait for a health check to succeed
    retries  = 3 # Number of retries before considering the container unhealthy
    start_period = "50s" # Time to wait before starting health checks
  }
}
