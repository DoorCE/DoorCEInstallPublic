locals {
  configuration = yamldecode(file(find_in_parent_folders("config.yaml")))
}


stack "incus.doorce.server" {
source = find_in_parent_folders("src/stacks/incus.doorce.server")
  path = "production/zone1"
  values = {
    configuration = local.configuration
    ssh_public_key = fileexists("/opt/github-runner/ssh/id_ed25519.pub") ? file("/opt/github-runner/ssh/id_ed25519.pub") : ""
  }
}
