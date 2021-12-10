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
  source   = "./modules/dashboard"
  username = local.dashboard_user
}

module "prometheus" {
  source           = "./modules/prometheus"
  grafana_password = local.grafana_password
  host_ip          = "192.168.86.10"
}

module "metallb" {
  source       = "./modules/metallb"
  address_pool = "192.168.86.128-192.168.86.255"
}

module "nginx" {
  depends_on              = [module.metallb]
  source                  = "./modules/nginx"
  prometheus_release_name = module.prometheus.release_name
  ingress_ip              = "192.168.86.200"
}

module "blocky" {
  depends_on              = [module.metallb]
  source                  = "./modules/blocky"
  prometheus_release_name = module.prometheus.release_name
  blocky_ip               = "192.168.86.201"
}
