resource "kubernetes_manifest" "traefik-config" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRouteUDP"

    metadata = {
      name      = "ingress-blocky-dns-udp"
      namespace = "default"
    }

    apiVersion = "helm.cattle.io/v1"
    kind       = "HelmChartConfig"

    metadata = {
      name      = "traefik"
      namespace = var.namespace
    }

    spec = yamlencode({
      valuesContent = {
        dashboard = {
          enabled = true
        }
        ports = {
          blocky-tcp = {
            expose   = true
            name     = local.blocky_tcp_port_name
            port     = 53
            protocol = "TCP"
          }
          blocky-udp = {
            expose   = true
            name     = local.blocky_udp_port_name
            port     = 53
            protocol = "UDP"
          }
          traefik = {
            expose = true
          }
        }
        securityContext = {
          capabilities = {
            add = ["NET_BIND_SERVICE"]
          }
          runAsGroup   = 0
          runAsNonRoot = false
          runAsUser    = 0
        }
      }
    })
  }
}
