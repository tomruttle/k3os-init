locals {
  dashboard_label = { app : "kubernetes-dashboard" }
  scraper_label   = { app : "dashboard-metrics-scraper" }
}

resource "kubernetes_namespace" "dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }
}
