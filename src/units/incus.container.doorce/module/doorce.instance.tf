resource "incus_instance" "doorce" {
  name      = "doorce"
  type      = "container"
  image     = "images:ubuntu/24.04/cloud"
  profiles  = [
    resource.incus_profile.doorce.name,
  ]
  ephemeral = false
  lifecycle {
    replace_triggered_by = [
      incus_profile.doorce
    ]
  }

}

# resource "terraform_data" "wait_for_ssh" {
#   # This ensures the check runs every time the instance ID changes (re-creation)
#   triggers_replace = [
#     incus_instance.doorce,
#   ]

#   provisioner "local-exec" {
#     command = <<EOT
#       echo "Waiting for instance ${incus_instance.doorce.name} to be ready..."
      
#       # 1. Wait for IP assignment
#       IP=""
#       ITER=0
#       while [ -z "$IP" ] && [ $ITER -lt 20 ]; do
#         IP=${incus_instance.doorce.ipv4_address}
#         if [ -z "$IP" ]; then
#           sleep 3
#           ITER=$((ITER+1))
#         fi
#       done

#       if [ -z "$IP" ]; then
#         echo "Timeout: No IP address assigned to ${incus_instance.doorce.name}"
#         exit 1
#       fi

#       # 2. Wait for SSH port 22
#       echo "Found IP: $IP. Waiting for SSH service..."
#       until nc -z -v -w2 "$IP" 22; do
#         sleep 2
#       done

#       echo "Instance ${incus_instance.doorce.name} is fully reachable via SSH at $IP."
#     EOT
#   }

#   depends_on = [incus_instance.doorce]
# }
