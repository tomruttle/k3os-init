terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
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
  source = "./modules/blocky"
}
