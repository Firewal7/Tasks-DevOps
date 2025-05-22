# network.tf

# Определение сети VPC
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

# Создание подсетей на основе переменной subnets
resource "yandex_vpc_subnet" "subnet" {
  for_each = var.subnets

  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = [each.value.cidr_block]
}