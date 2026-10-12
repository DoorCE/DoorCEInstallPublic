resource "terraform_data" "keycloak_wait_complete" {
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
      sleep 5 # Initial wait before starting checks
      URL="${local.public_site_url}"
      TIMEOUT=120
      INTERVAL=5
      ELAPSED=0
      while [ $ELAPSED -lt $TIMEOUT ]; do
        STATUS=$(curl -s -o /dev/null -w "%%{http_code}" -k "$URL")

        if [ "$STATUS" = "200" ]; then
          echo "SUCCESS: Keycloak returned 200 OK at $URL"
          exit 0
        fi

        echo "Waiting for Keycloak... Status: $STATUS ($ELAPSED / $TIMEOUT s)"
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
      done

      echo "ERROR: Timeout reached ($TIMEOUT s). Keycloak is not responding."
      exit 1
    EOT
  }

  lifecycle {
    replace_triggered_by = [
    ]
  }
}