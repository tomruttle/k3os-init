resource "helm_release" "traefik" {
  name      = "traefik"
  namespace = var.namespace

  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"

  set {
    name  = "rbac.enabled"
    value = true
  }

  set {
    name  = "dashboard.enabled"
    value = true
  }

  set {
    name = "ports.${local.blocky_udp_port_name}"
    value = yamlencode({
      name     = local.blocky_udp_port_name
      port     = 53
      protocol = "UDP"
      expose   = true
    })
  }

  set {
    name = "ports.${local.blocky_tcp_port_name}"
    value = yamlencode({
      name     = local.blocky_tcp_port_name
      port     = 53
      protocol = "TCP"
      expose   = true
    })
  }

  set {
    name  = "ports.traefik.expose"
    value = true
  }

  set {
    name  = "ports.websecure.tls.enabled"
    value = true
  }

  set {
    name  = "providers.kubernetesIngress.publishedService.enabled"
    value = true
  }

  set {
    name  = "priorityClassName"
    value = "system-cluster-critical"
  }

  set {
    name = "securityContext"
    value = yamlencode({
      runAsGroup   = 0
      runAsNonRoot = false
      runAsUser    = 0
      capabilities = {
        add = ["NET_BIND_SERVICE"]
      }
    })
  }

  set {
    name = "tolerations"
    value = yamlencode([
      {
        key      = "CriticalAddonsOnly"
        operator = "Exists"
      },
      {
        key      = "node-role.kubernetes.io/control-plane"
        operator = "Exists"
        effect   = "NoSchedule"
      },
      {
        key      = "node-role.kubernetes.io/master"
        operator = "Exists"
        effect   = "NoSchedule"
      }
    ])
  }
}
