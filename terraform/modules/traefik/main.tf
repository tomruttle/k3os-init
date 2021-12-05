resource "kubernetes_manifest" "traefik_config" {
  manifest = {
    apiVersion = "helm.cattle.io/v1"
    kind       = "HelmChartConfig"

    metadata = {
      name      = "traefik"
      namespace = var.namespace
    }

    spec = yamlencode({
      "valuesContent" = {
        "dashboard" = {
          "enabled" = true
        }

        "ports" = {
          "blocky-tcp" = {
            "expose"   = true
            "name"     = "blocky-tcp"
            "port"     = 53
            "protocol" = "TCP"
          }

          "blocky-udp" = {
            "expose"   = true
            "name"     = "blocky-udp"
            "port"     = 53
            "protocol" = "UDP"
          }

          "traefik" = {
            "expose" = true
          }
        }

        "securityContext" = {
          "capabilities" = {
            "add" = ["NET_BIND_SERVICE"]
          }

          "runAsGroup"   = 0
          "runAsNonRoot" = false
          "runAsUser"    = 0
        }
      }
    })
  }
}
