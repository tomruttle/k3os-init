resource "helm_release" "blocky" {
  name       = "blocky"
  namespace  = "default"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "blocky"

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

  values = [
    yamlencode({
      service = {
        dns = {
          enabled               = true
          type                  = "LoadBalancer"
          externalTrafficPolicy = "Local"
          loadBalancerIP        = var.blocky_ip
          ports = {
            "dns-tcp" = {
              enabled    = true
              port       = 53
              protocol   = "TCP"
              targetPort = 53
            }
            "dns-udp" = {
              enabled    = true
              port       = 53
              protocol   = "UDP"
              targetPort = 53
            }
          }
        }
      }
    })
  ]
}
