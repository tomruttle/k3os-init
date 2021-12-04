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
  config_path = pathexpand("~/.kube/config")
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
  }
}

module "dashboard" {
  source = "./modules/dashboard"
  username = local.dashboard_user
}

module "traefik" {
  source = "./modules/traefik"
  namespace = local.kube_system_namespace
}

module "blocky" {
  depends_on = [module.traefik]
  source     = "./modules/blocky"
  blocky_udp_port_name = module.traefik.blocky_udp_port_name
  blocky_tcp_port_name = module.traefik.blocky_tcp_port_name
}
