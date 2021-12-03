resource "kubernetes_service_account" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "kube-system"
    labels    = { app : "traefik" }
  }
}

resource "kubernetes_deployment" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "kube-system"
    labels    = { app : "traefik" }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "traefik"
      }
    }

    template {
      metadata {
        labels = { app = "traefik" }
      }

      spec {
        serviceAccountName = kubernetes_service_account.traefik.metadata.0.name

        priority_class_name = "system-cluster-critical"

        toleration {
          kkey     = "CriticalAddonsOnly"
          operator = "Exists"
        }

        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        container {
          name  = "traefik"
          image = "traefik:v2.2"

          args = [
            "--api.insecure",
            "--accesslog",
            "--entrypoints.web.Address=:80",
            "--entrypoints.websecure.Address=:443",
            "--providers.kubernetescrd",
            "--certificatesresolvers.myresolver.acme.tlschallenge",
            "--certificatesresolvers.myresolver.acme.email=foo@you.com",
            "--certificatesresolvers.myresolver.acme.storage=acme.json",
          ]

          port {
            name           = "web"
            container_port = 80
            protocol       = "TCP"
          }

          port {
            name           = "websecure"
            container_port = 443
            protocol       = "TCP"
          }

          port {
            name           = "admin"
            container_port = 8080
            protocol       = "TCP"
          }

          #     rbac:
          #       enabled: true
          #     ports:
          #       websecure:
          #         tls:
          #           enabled: true
          #     podAnnotations:
          #       prometheus.io/port: "8082"
          #       prometheus.io/scrape: "true"
          #     providers:
          #       kubernetesIngress:
          #         publishedService:
          #           enabled: true

          security_context {
            run_as_group    = 0
            run_as_non_root = false
            run_run_as_user = 0

            capabilities {
              add = ["NET_BIND_SERVICE"]
            }
          }

          # dashboard:
          #   enabled: true
          # ports:
          #   traefik:
          #     expose: true
          #   blocky-udp:
          #     name: blocky-udp
          #     port: 53
          #     protocol: UDP
          #     expose: true
          #   blocky-tcp:
          #     name: blocky-tcp
          #     port: 53
          #     protocol: TCP
          #     expose: true
        }
      }
    }
  }
}

resource "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "kube-system"
    labels    = { app : "traefik" }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app : kubernetes_deployment.traefik.spec.0.template.0.metadata.0.labels.app
    }

    port {
      name     = "web"
      port     = 80
      protocol = "TCP"
    }

    port {
      name     = "admin"
      port     = 8080
      protocol = "TCP"
    }

    port {
      name     = "websecure"
      port     = 443
      protocol = "TCP"
    }
  }
}
