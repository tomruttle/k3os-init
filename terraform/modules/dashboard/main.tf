resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }
}

resource "helm_release" "dashboard" {
  name      = "kubernetes-dashboard"
  namespace = "kubernetes-dashboard"

  repository = "https://kubernetes.github.io/dashboard"
  chart      = "kubernetes-dashboard"
}

resource "kubernetes_service_account" "user" {
  metadata {
    name      = var.username
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }
}

resource "kubernetes_cluster_role_binding" "user" {
  metadata {
    name   = var.username
    labels = local.dashboard_label
  }

  role_ref {
    kind      = "ClusterRole"
    api_group = "rbac.authorization.k8s.io"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    name      = kubernetes_service_account.user.metadata.0.name
  }
}