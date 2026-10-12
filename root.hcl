# Generate the Terraform remote backend configuration for tfc.
generate "backend" {
  path      = "_backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "local" {
    path = "/opt/github-runner/state/${replace(path_relative_to_include(), ".terragrunt-stack/", "")}/terraform.tfstate"
  }
}
EOF
}



# Generate the Terraform required_providers configuration file.
generate "terraform" {
  path      = "_terraform.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.9"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "~> 1.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.70.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = "~> 5.6"
    }
    incus = {
      source = "lxc/incus"
      version = "1.0.2"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.2.1"
    }
    # aws = {
    #   source = "hashicorp/aws"
    #   version = "6.40.0"
    # }
  }
}
EOF
}
