resource "terraform_data" "ckan_base_wait_complete" {
  depends_on = [
    docker_container.this,
  ]
  triggers_replace = [
    docker_container.this.id,
    local.public_site_url,
  ]

  input = local.public_site_url

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    
  command = <<EOT
      sleep 5 
      URL="${local.public_site_url}"
      TIMEOUT=120
      INTERVAL=5
      ELAPSED=0

      while [ $ELAPSED -lt $TIMEOUT ]; do
        STATUS=$(curl -s -o /dev/null -w "%%{http_code}" -k "$URL")

        if [ "$STATUS" = "200" ]; then
          echo "SUCCESS: CKAN returned 200 OK at $URL"
          exit 0
        fi

        echo "Waiting for CKAN... Status: $STATUS ($ELAPSED / $TIMEOUT s)"
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
      done

      echo "ERROR: Timeout reached. Last status was $STATUS."
      exit 1
    EOT
  }

  lifecycle {
    replace_triggered_by = [
    ]
  }
}


data "external" "ckan_admin_token" {
  depends_on = [terraform_data.ckan_base_wait_complete]

  program = ["bash", "-c", <<-EOT
    eval "$(jq -r '@sh "SSH_HOST=\(.ssh_host) SSH_KEY_PATH=\(.ssh_key_path) SSH_USER=\(.ssh_user) SSH_PORT=\(.ssh_port) CONTAINER=\(.container_name) TOKEN_PATH=\(.file_path)"')"

    JWT=$(ssh -n -o BatchMode=yes \
      -o ConnectTimeout=5 \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -i "$SSH_KEY_PATH" -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" \
      "docker exec $CONTAINER cat $TOKEN_PATH" 2>/dev/null | tr -d '\r\n')

    if [ -z "$JWT" ]; then
      echo '{"token": ""}'
    else
      echo "{\"token\": \"$JWT\"}"
    fi
  EOT
  ]

  query = {
    ssh_host       = var.ssh_host
    ssh_user       = var.ssh_user
    ssh_port       = var.ssh_port
    ssh_key_path   = var.ssh_key_path
    container_name = docker_container.this.name
    file_path      = local.ckan_admin_api_token_path
  }
}

