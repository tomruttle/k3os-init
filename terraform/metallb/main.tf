resource "kubernetes_namespace" "metallb_system" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  namespace  = kubernetes_namespace.metallb_system.metadata.0.name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"

  set {
    name = "configInline"
    value = yamlencode({
      "address-pools" = [
        {
          name      = "default"
          protocol  = "layer2"
          addresses = ["192.168.86.100-192.168.86.255"]
        }
      ]
    })
  }
}
