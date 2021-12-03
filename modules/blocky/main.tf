resource "helm_release" "blocky" {
  name      = "blocky"
  namespace = "default"

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

  values = [
    <<EOT
config: |
  upstream:
    externalResolvers:
      - 8.8.8.8
      - 8.8.4.4
      - tcp-tls:fdns1.dismail.de:853
      - https://dns.digitale-gesellschaft.ch/dns-query

  blocking:
    blackLists:
      ads:
        - https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
        - https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
        - https://mirror1.malwaredomains.com/files/justdomains
        - http://sysctl.org/cameleon/hosts
        - https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist
        - https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
      special:
        - https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts

    clientGroupsBlock:
      default:
        - ads
        - special

    blockType: zeroIp
    refreshPeriod: 0

  caching:
    minTime: 5
    maxTime: -1
    prefetching: true

  port: 53
  httpPort: 4000
  bootstrapDns: tcp:1.1.1.1
  logLevel: info
  logFormat: text
EOT
  ]
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
      entryPoints = ["blocky-udp"]

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
      entryPoints = ["blocky-tcp"]

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
