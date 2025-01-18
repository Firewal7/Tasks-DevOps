# outputs.tf

output "kafka01_external_ipv4" {
  value = yandex_compute_instance.instances["kafka01"].network_interface[0].nat_ip_address
}

output "web01_external_ipv4" {
  value = yandex_compute_instance.instances["web01"].network_interface[0].nat_ip_address
}

output "db01_external_ipv4" {
  value = yandex_compute_instance.instances["db01"].network_interface[0].nat_ip_address
}
