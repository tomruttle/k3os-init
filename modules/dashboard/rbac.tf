resource "kubernetes_service_account" "dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }
}

resource "kubernetes_role" "dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }

  # Allow Dashboard to get, update and delete Dashboard exclusive secrets.
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    resource_names = [
      kubernetes_secret.dashboard_key_holder.metadata.0.name,
      kubernetes_secret.dashboard_certs.metadata.0.name,
      kubernetes_secret.dashboard_csrf.metadata.0.name,
    ]
    verbs = ["get", "update", "delete"]
  }

  # Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = [kubernetes_config_map.dashboard_settings.metadata.0.name]
    verbs          = ["get", "update"]
  }

  # Allow Dashboard to get metrics.
  rule {
    api_groups     = [""]
    resources      = ["services"]
    resource_names = ["heapster", "dashboard-metrics-scraper"]
    verbs          = ["proxy"]
  }

  rule {
    api_groups     = [""]
    resources      = ["services/proxy"]
    resource_names = ["heapster", "http:heapster:", "https:heapster:", "dashboard-metrics-scraper", "http:dashboard-metrics-scraper"]
    verbs          = ["get"]
  }
}

resource "kubernetes_cluster_role" "dashboard" {
  metadata {
    name   = "kubernetes-dashboard"
    labels = local.dashboard_label
  }

  # Allow Metrics Scraper to get metrics from the Metrics server
  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }

  role_ref {
    kind      = "Role"
    api_group = "rbac.authorization.k8s.io"
    name      = kubernetes_role.dashboard.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    name      = kubernetes_service_account.dashboard.metadata.0.name
  }
}

resource "kubernetes_cluster_role_binding" "dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }

  role_ref {
    kind      = "ClusterRole"
    api_group = "rbac.authorization.k8s.io"
    name      = kubernetes_cluster_role.dashboard.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    name      = kubernetes_service_account.dashboard.metadata.0.name
  }
}

resource "kubernetes_service_account" "tom" {
  metadata {
    name      = "tom"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }
}

resource "kubernetes_cluster_role_binding" "tom" {
  metadata {
    name   = "tom"
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
    name      = kubernetes_service_account.tom.metadata.0.name
  }
}