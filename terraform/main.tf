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
  source     = "./modules/dashboard"
  username   = local.dashboard_user
}

module "prometheus" {
  source = "./modules/prometheus"
}

module "metallb" {
  source       = "./modules/metallb"
  address_pool = "192.168.86.128-192.168.86.255"
}

module "nginx" {
  depends_on = [module.metallb]
  source     = "./modules/nginx"
  ingress_ip = "192.168.86.200"
}

module "blocky" {
  depends_on = [module.metallb]
  source     = "./modules/blocky"
  blocky_ip  = "192.168.86.201"
}
