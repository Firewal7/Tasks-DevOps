# locals.tf

locals {
  instances = {
    kafka01 = {
      subnet_key = "central1-a"
      platform   = "standard-v1"
    }
    web01 = {
      subnet_key = "central1-b"
      platform   = "standard-v1"
    }
    db01 = {
      subnet_key = "central1-d"
      platform   = "standard-v2"
    }
  }
}