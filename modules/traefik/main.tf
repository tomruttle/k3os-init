resource "helm_release" "traefik" {
  name      = "traefik"
  namespace = "kube-system"

  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"

  set {
    name  = "rbac.enabled"
    value = true
  }

  set {
    name  = "dashboard.enabled"
    value = true
  }

  set {
    name  = "ports.traefik.expose"
    value = true
  }

  set {
    name  = "ports.websecure.tls.enabled"
    value = true
  }

  set {
    name  = "providers.kubernetesIngress.publishedService.enabled"
    value = true
  }

  set {
    name  = "priorityClassName"
    value = "system-cluster-critical"
  }

  values = [
    <<EOT
ports:
  blocky-udp:
    name: blocky-udp
    port: 53
    protocol: UDP
    expose: true
  blocky-tcp:
    name: blocky-tcp
    port: 53
    protocol: TCP
    expose: true
securityContext:
  capabilities:
    add: [NET_BIND_SERVICE]
  runAsGroup: 0
  runAsNonRoot: false
  runAsUser: 0
tolerations:
- key: "CriticalAddonsOnly"
  operator: "Exists"
- key: "node-role.kubernetes.io/control-plane"
  operator: "Exists"
  effect: "NoSchedule"
- key: "node-role.kubernetes.io/master"
  operator: "Exists"
  effect: "NoSchedule"
EOT
  ]
}
