resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_controller" {
  name       = "ingress-controller"
  namespace  = kubernetes_namespace.ingress_nginx.metadata.0.name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.ingress_ip
  }

  set {
    name  = "controller.metrics.enabled"
    value = true
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "controller.metrics.serviceMonitor.additionalLabels.release"
    value = var.prometheus_release_name
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/port"
    value = 10254
    type  = "string"
  }

  set {
    name  = "controller.metrics.service.annotations.prometheus\\.io/scrape"
    value = true
    type  = "string"
  }

  values = [
    yamlencode({
      tolerations = [
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
      ]
    })
  ]
}
