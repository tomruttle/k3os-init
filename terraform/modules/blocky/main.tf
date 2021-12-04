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

resource "kubernetes_manifest" "ingress-blocky-dns-udp" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRouteUDP"

    metadata = {
      name      = "ingress-blocky-dns-udp"
      namespace = "default"
    }

    spec = {
      entryPoints = [var.blocky_udp_port_name]

      routes = [
        {
          services = [
            {
              name = "blocky-dns-udp"
              port = 53
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "ingress-blocky-dns-tcp" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRouteTCP"

    metadata = {
      name      = "ingress-blocky-dns-tcp"
      namespace = "default"
    }

    spec = {
      entryPoints = [var.blocky_tcp_port_name]

      routes = [
        {
          match = "HostSNI(`*`)"
          services = [
            {
              name = "blocky-dns-tcp"
              port = 53
            }
          ]
        }
      ]
    }
  }
}
