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
      IMAGE_NAME   = var.image_name
      IMAGE_VERSION = var.image_version
    }
    tag = [
      "${var.name}:${var.image_version}",
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
    for_each = [var.network_for_clients]
    content {
      name = networks_advanced.value
    }
  }

  env = [
    "POSTGRES_HOST=${var.name}",
    "POSTGRES_DB=${var.db_postgres}",
    "POSTGRES_USER=${var.db_postgres_user}",
    "POSTGRES_PASSWORD=${random_password.db_postgres_password.result}",
    "DB_UDAS_USER=${var.db_udas_username}",
    "DB_UDAS_PASSWORD=${random_password.db_udas_password.result}",
    "DB_UDAS_NAME=${var.db_udas_database}",
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
