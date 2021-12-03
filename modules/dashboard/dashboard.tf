resource "kubernetes_secret" "dashboard_certs" {
  metadata {
    name      = "kubernetes-dashboard-certs"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }

  type = "Opaque"
}

resource "kubernetes_secret" "dashboard_csrf" {
  metadata {
    name      = "kubernetes-dashboard-csrf"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }

  type = "Opaque"
  data = { csrf : "" }
}

resource "kubernetes_secret" "dashboard_key_holder" {
  metadata {
    name      = "kubernetes-dashboard-key-holder"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "dashboard_settings" {
  metadata {
    name      = "kubernetes-dashboard-settings"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }
}

resource "kubernetes_deployment" "dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }

  spec {
    replicas               = 1
    revision_history_limit = 10

    selector {
      match_labels = local.dashboard_label
    }

    template {
      metadata {
        labels = local.dashboard_label
      }

      spec {
        service_account_name = kubernetes_service_account.dashboard.metadata.0.name

        node_selector = {
          "kubernetes.io/os" : "linux"
        }

        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }

        container {
          name              = "kubernetes-dashboard"
          image             = "kubernetesui/dashboard:v2.4.0"
          image_pull_policy = "Always"
          args              = ["--auto-generate-certificates", "--namespace=kubernetes-dashboard"]

          port {
            container_port = 8443
            protocol       = "TCP"
          }

          volume_mount {
            name       = "kubernetes-dashboard-certs"
            mount_path = "/certs"
          }

          # Create on-disk volume to store exec logs
          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }

          liveness_probe {
            http_get {
              scheme = "HTTPS"
              path   = "/"
              port   = 8443
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
          name = "kubernetes-dashboard-certs"
          secret {
            secret_name = kubernetes_secret.dashboard_certs.metadata.0.name
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

resource "kubernetes_service" "dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.dashboard.metadata.0.name
    labels    = local.dashboard_label
  }

  spec {
    type = "NodePort"

    selector = {
      app = kubernetes_deployment.dashboard.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 443
      target_port = 8443
    }
  }
}
