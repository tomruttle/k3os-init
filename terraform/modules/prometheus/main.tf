resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = kubernetes_namespace.prometheus.metadata.0.name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  # set {
  #   name  = "kubeControllerManager.endpoints"
  #   value = "{192.168.86.10}"
  # }

  set {
    name  = "kubeControllerManager.service.port"
    value = 10257
  }

  set {
    name  = "kubeControllerManager.service.targetPort"
    value = 10257
  }

  set {
    name  = "kubeControllerManager.serviceMonitor.https"
    value = true
  }

  set {
    name  = "kubeControllerManager.serviceMonitor.insecureSkipVerify"
    value = true
  }

  # set {
  #   name  = "kubeEtcd.endpoints"
  #   value = "{192.168.86.10}"
  # }

  set {
    name  = "kubeEtcd.service.port"
    value = 2381
  }

  set {
    name  = "kubeEtcd.service.targetPort"
    value = 2381
  }

  # set {
  #   name  = "kubeProxy.endpoints"
  #   value = "{192.168.86.10}"
  # }

  # set {
  #   name  = "kubeScheduler.endpoints"
  #   value = "{192.168.86.10}"
  # }

  set {
    name  = "kubeScheduler.service.port"
    value = 10259
  }

  set {
    name  = "kubeScheduler.service.targetPort"
    value = 10259
  }

  set {
    name  = "kubeScheduler.serviceMonitor.https"
    value = true
  }

  set {
    name  = "kubeScheduler.serviceMonitor.insecureSkipVerify"
    value = true
  }
}


