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

module "metallb" {
  source = "./modules/metallb"
}

module "dashboard" {
  depends_on = [module.metallb]

  source   = "./modules/dashboard"
  username = local.dashboard_user
}

module "blocky" {
  depends_on = [module.metallb]
  source = "./modules/blocky"
}

module "nginx" {
  depends_on         = [module.blocky, module.metallb]
  source             = "./modules/nginx"
  blocky_namespace   = module.blocky.namespace
  blocky_tcp_service = module.blocky.tcp_service
  blocky_udp_service = module.blocky.udp_service
}
