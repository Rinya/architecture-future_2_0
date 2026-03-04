variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
}

variable "yc_zone" {
  type        = string
  description = "Yandex Cloud zone"
  default     = "ru-central1-a"
}

variable "subnets" {
  type = map(object({
    zone = string
    cidr = string
  }))
  default = {
    "web-subnet" = {
      zone = "ru-central1-a"
      cidr = "192.168.10.0/24"
    }
    "db-subnet" = {
      zone = "ru-central1-a"
      cidr = "192.168.20.0/24"
    }
    "db-subnet-b" = {
      zone = "ru-central1-b"
      cidr = "192.168.21.0/24"
    }
  }
}

variable "vm_instances" {
  type = map(object({
    zone      = string
    subnet    = string
    cores     = number
    memory    = number
    disk_size = number
  }))
  default = {
    "web-vm" = {
      zone      = "ru-central1-a"
      subnet    = "web-subnet"
      cores     = 2
      memory    = 2
      disk_size = 15
    }
  }
}

variable "bucket_name" {
  type    = string
  default = "terraform-state-bucket"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "enable_auto_cleanup" {
  description = "Автоматически удалять ресурсы при ошибках"
  type        = bool
  default     = true
}
