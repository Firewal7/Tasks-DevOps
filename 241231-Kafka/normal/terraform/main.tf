# main.tf

resource "yandex_compute_instance" "instances" {
  for_each = local.instances

  name        = each.value.name
  hostname    = each.value.name
  zone        = each.value.zone
  platform_id = each.value.platform

  resources {
    cores         = var.public_resources.cores
    memory        = var.public_resources.memory
    core_fraction = var.public_resources.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.public_image
      size     = var.public_resources.size
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = each.value.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }
}