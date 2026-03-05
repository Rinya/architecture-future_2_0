terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
	tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

resource "null_resource" "error_handler" {
  count = var.enable_auto_cleanup ? 1 : 0

  triggers = {
    deployment_id = sha1(join("", [for key, value in var.vm_instances : key]))
  }

  provisioner "local-exec" {
    when        = create
    command     = <<EOT
      # Сохраняем текущее состояние
      terraform state list > .terraform-state-before.txt
    EOT
    on_failure  = continue
  }

  provisioner "local-exec" {
    when        = create
    command     = "terraform state list > .terraform-state-before.txt"
    on_failure  = continue
    interpreter = ["/bin/bash", "-c"] # для Linux/Mac
    # interpreter = ["cmd", "/C"] # для Windows
  }
}

# Генерация SSH-ключа
resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Сохранение приватного ключа в файл
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.vm_ssh_key.private_key_openssh
  filename        = "${path.module}/generated_ssh_key.pem"
  file_permission = "0600"
}


# Создание VPC сети
resource "yandex_vpc_network" "main" {
  name        = "main-network"
  description = "Основная сеть для инфраструктуры"
}

# Создание подсетей
resource "yandex_vpc_subnet" "subnets" {
  for_each = var.subnets

  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]

  # Зависимость от успешного создания сети
  depends_on = [yandex_vpc_network.main]
}

# Группы безопасности
resource "yandex_vpc_security_group" "main" {
  name        = "main-security-group"
  description = "Основная группа безопасности"
  network_id  = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "SSH access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Сервисный аккаунт для IAM
resource "yandex_iam_service_account" "main" {
  name        = "terraform-sa"
  description = "Service account for Terraform managed resources"
}

# Роли для сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.main.id}"
}

# роль storage.admin для Object Storage
resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.yc_folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.main.id}"
}

# статические ключи доступа
resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = yandex_iam_service_account.main.id
  description        = "Static access key for object storage"
}

# Управляемая база данных PostgreSQL
resource "yandex_mdb_postgresql_cluster" "main_db" {
  name        = "main-postgresql-cluster"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.main.id

  config {
    version = 15
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  # Минимум 2 хоста для HA
  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.subnets["db-subnet"].id
  }

  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.subnets["db-subnet-b"].id
  }
  
  # Зависимость от подсетей и группы безопасности
  depends_on = [
    yandex_vpc_subnet.subnets["db-subnet"],
    yandex_vpc_subnet.subnets["db-subnet-b"],
    yandex_vpc_security_group.main
  ]
}

# Object Storage
resource "yandex_storage_bucket" "main" {
  bucket     = "${var.bucket_name}-${random_id.bucket_suffix.hex}"
  access_key = yandex_iam_service_account_static_access_key.sa_static_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa_static_key.secret_key
  
  depends_on = [
    yandex_iam_service_account_static_access_key.sa_static_key
  ]
}

# Добавляем случайный суффикс к имени бакета
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Виртуальные машины
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Виртуальные машины
resource "yandex_compute_instance" "vms" {
  for_each = var.vm_instances

  name        = each.key
  zone        = each.value.zone
  platform_id = "standard-v3"

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = each.value.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnets[each.value.subnet].id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.vm_ssh_key.public_key_openssh}"
  }
  
  depends_on = [
    null_resource.error_handler,
    yandex_vpc_subnet.subnets,
    yandex_vpc_security_group.main
  ]
}
