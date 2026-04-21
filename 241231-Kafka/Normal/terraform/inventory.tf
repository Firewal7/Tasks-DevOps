# inventory.tf

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory/hosts"
  content  = <<EOF
all:
  vars:
    ansible_user: ${var.ssh_user}
    ansible_ssh_private_key_file: ${var.ssh_private_key_path}
    ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'

kafka:
  hosts:
    kafka01:
      ansible_host: ${yandex_compute_instance.instances["kafka01"].network_interface[0].nat_ip_address}

kafka_ui:
  hosts:
    web01:
      ansible_host: ${yandex_compute_instance.instances["web01"].network_interface[0].nat_ip_address}

clickhouse:
  hosts:
    db01:
      ansible_host: ${yandex_compute_instance.instances["db01"].network_interface[0].nat_ip_address}
EOF
}
