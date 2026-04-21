# outputs.tf

output "instances_external_ipv4" {
  value = {
    for name, inst in yandex_compute_instance.instances :
    name => inst.network_interface[0].nat_ip_address
  }
}