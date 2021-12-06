resource "helm_release" "blocky" {
  name       = "blocky"
  namespace  = "default"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "blocky"

  set {
    name  = "service.dns-udp.enabled"
    value = true
  }

  set {
    name  = "service.dns-tcp.enabled"
    value = true
  }

  set {
    name = "config"
    value = yamlencode({
      blocking = {
        blackLists = {
          ads = [
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt",
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
            "http://sysctl.org/cameleon/hosts",
            "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt",
          ]
          special = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts",
          ]
        }
        blockType = "zeroIp"
        clientGroupsBlock = {
          default = [
            "ads",
            "special",
          ]
        }
        refreshPeriod = 0
      }
      bootstrapDns = "1.1.1.1"
      prometheus = {
        enable = true
      }
      caching = {
        maxTime     = -1
        minTime     = 5
        prefetching = true
      }
      httpPort  = 4000
      logFormat = "text"
      logLevel  = "info"
      port      = 53
      upstream = {
        default = [
          "8.8.8.8",
          "8.8.4.4",
          "tcp-tls:fdns1.dismail.de:853",
          "https://dns.digitale-gesellschaft.ch/dns-query",
        ]
      }
    })
  }
}

resource "kubernetes_ingress" "ingress_blocky_dns_udp" {
  metadata {
    name      = "ingress-blocky-dns-udp"
    namespace = "default"
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" : var.blocky_udp_port_name
    }
  }
  spec {
    backend {
      service_name = "blocky-dns-udp"
      service_port = 53
    }
  }
}

resource "kubernetes_ingress" "ingress_blocky_dns_tcp" {
  metadata {
    name      = "ingress-blocky-dns-tcp"
    namespace = "default"
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" : var.blocky_tcp_port_name
    }
  }
  spec {
    backend {
      service_name = "blocky-dns-tcp"
      service_port = 53
    }
  }
}
