# variables.tf

#Аутентификация:
## Токен Yandex.Cloud

variable "token" {
  type        = string
  sensitive = true
  description = "Your Yandex.Cloud API token"
}

## Cloud ID

variable "cloud_id" {
  type        = string
  description = "Your Yandex.Cloud Cloud ID"
}

## Folder ID

variable "folder_id" {
  type        = string
  description = "Your Yandex.Cloud Folder ID"
}

#Сеть:
## Имя сети VPC
variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "Name for VPC network & subnets"
}

## Подсети
variable "subnets" {
  type = map(object({
    zone       = string
    cidr_block = string
  }))
  default = {
    "central1-a" = { zone = "ru-central1-a", cidr_block = "10.0.1.0/24" }
    "central1-b" = { zone = "ru-central1-b", cidr_block = "10.0.2.0/24" }
    "central1-d" = { zone = "ru-central1-d", cidr_block = "10.0.3.0/24" }
  }
}

#Ресурсы:
## ID образа Yandex.Compute

variable "public_image" {
  type        = string
  default     = "fd8tvc3529h2cpjvpkr5"
  description = "Yandex.Compute image ID"
}

## Ресурсы для виртуальных машин

variable "public_resources" {
  type = object({
    cores          = number
    memory         = number
    core_fraction  = number
    size           = number
  })
  default = {
    cores          = 2
    memory         = 2
    core_fraction  = 20
    size           = 30
  }
}

# SSH:
## Подключение по SSH user

variable "ssh_user" {
  type    = string
  default = "ubuntu" # Укажите имя пользователя
}

## Путь к публичному ключу (вынесен в personal.auto.tfvars)
variable "ssh_public_key_path" {
  type        = string
  sensitive = true
  description = "Path to the SSH public key"
}

## Путь к приватному ключу (вынесен в personal.auto.tfvars)
variable "ssh_private_key_path" {
  type        = string
  sensitive = true
  description = "Path to the SSH private key"
}