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
    name = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name = "controller.service.loadBalancerIP"
    value = var.ingress_ip
  }

  # set {
  #   name  = "controller.metrics.enabled"
  #   value = true
  # }

  # set {
  #   name  = "controller\\.metrics\\.service\\.annotations\\.\"prometheus\\.io/scrape\""
  #   value = true
  # }

  # set {
  #   name  = "controller.metrics.service.annotations.\"prometheus\\.io/port\""
  #   value = 10254
  # }

  # set {
  #   name  = "controller.podAnnotations.\"prometheus\\.io/scrape\""
  #   value = true
  # }

  # set {
  #   name  = "controller.podAnnotations.\"prometheus\\.io/port\""
  #   value = 10254
  # }

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
