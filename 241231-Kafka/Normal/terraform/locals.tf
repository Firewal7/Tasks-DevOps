# locals.tf

locals {
  instances = {
    kafka01 = {
      name       = "kafka01"
      zone       = var.subnets["central1-a"].zone
      subnet_id  = yandex_vpc_subnet.subnet["central1-a"].id
      platform   = "standard-v1"
    }
    web01 = {
      name       = "web01"
      zone       = var.subnets["central1-b"].zone
      subnet_id  = yandex_vpc_subnet.subnet["central1-b"].id
      platform   = "standard-v1"
    }
    db01 = {
      name       = "db01"
      zone       = var.subnets["central1-d"].zone
      subnet_id  = yandex_vpc_subnet.subnet["central1-d"].id
      platform   = "standard-v2"
    }
  }
}