terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ruttle-net"

    workspaces {
      name = "k3s-master"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "dashboard" {
  source = "./modules/dashboard"
}

module "traefik" {
  source = "./modules/traefik"
}

module "blocky" {
  depends_on = [module.traefik]
  source     = "./modules/blocky"
}
