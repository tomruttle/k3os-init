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
    name  = "tcp.5353"
    value = "${var.blocky_namespace}/${var.blocky_tcp_service}:53"
  }

  set {
    name  = "udp.53"
    value = "${var.blocky_namespace}/${var.blocky_udp_service}:53"
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
