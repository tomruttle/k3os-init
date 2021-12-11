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

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }

  set {
    name  = "grafana.ingress.enabled"
    value = true
  }

  set {
    name  = "grafana.ingress.annotations.kubernetes\\.io/ingress\\.class"
    value = "nginx"
    type  = "string"
  }

  set {
    name  = "grafana.ingress.hosts"
    value = "{${var.grafana_hostname}}"
  }

  set {
    name  = "kubeControllerManager.endpoints"
    value = "{${var.host_ip}}"
  }

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

  set {
    name  = "kubeEtcd.endpoints"
    value = "{${var.host_ip}}"
  }

  set {
    name  = "kubeEtcd.service.port"
    value = 2381
  }

  set {
    name  = "kubeEtcd.service.targetPort"
    value = 2381
  }

  set {
    name  = "kubeProxy.endpoints"
    value = "{${var.host_ip}}"
  }

  set {
    name  = "kubeScheduler.endpoints"
    value = "{${var.host_ip}}"
  }

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
