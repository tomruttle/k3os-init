output "namespace" {
  value = helm_release.blocky.namespace
}

output "udp_service" {
  value = "blocky-dns-udp"
}

output "tcp_service" {
  value = "blocky-dns-tcp"
}
