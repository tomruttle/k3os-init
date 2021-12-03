resource "kubernetes_deployment" "metrics_scraper" {
  metadata {
    name      = "dashboard-metrics-scraper"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.scraper_label
  }

  spec {
    replicas               = 1
    revision_history_limit = 10

    selector {
      match_labels = local.scraper_label
    }

    template {
      metadata {
        labels = local.scraper_label
      }

      spec {
        service_account_name = kubernetes_service_account.dashboard.metadata.0.name

        node_selector = {
          "kubernetes.io/os" : "linux"
        }

        # ??????
        #       securityContext:
        #         seccompProfile:
        #           type: RuntimeDefault

        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }

        container {
          name  = "dashboard-metrics-scraper"
          image = "kubernetesui/metrics-scraper:v1.0.7"

          port {
            container_port = 8080
            protocol       = "TCP"
          }

          # Create on-disk volume to store exec logs
          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }

          liveness_probe {
            http_get {
              scheme = "HTTP"
              path   = "/"
              port   = 8000
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_user                = 1001
            run_as_group               = 2001
          }
        }

        volume {
          name = "tmp-volume"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "metrics_scraper" {
  metadata {
    name      = "dashboard-metrics-scraper"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.scraper_label
  }

  spec {
    selector = {
      app = kubernetes_deployment.metrics_scraper.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 8000
      target_port = 8000
    }
  }
}