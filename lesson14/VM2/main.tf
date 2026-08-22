terraform {
  required_providers {
    cloudru = {
      source  = "cloud.ru/cloudru/cloud"
      version = "2.0.0"
    }
  }
}

provider "cloudru" {
  project_id  = var.project_id
  auth_key_id = var.auth_key_id
  auth_secret = var.auth_secret

  endpoints = {
    iam_endpoint     = "iam.api.cloud.ru:443"
    compute_endpoint = "compute.api.cloud.ru:443"
  }
}
resource "cloudru_evolution_compute_vm" "task2" {
  project_id  = var.project_id
  name        = "task2"
  zone_identifier = { name = "ru.AZ-2" }
  flavor_identifier = { name = "gen-1-1" }
  description = ""

  disk_identifiers = [{ disk_id = cloudru_evolution_compute_disk.task2.id }]
  network_interfaces = [{ interface_id = cloudru_evolution_compute_interface.task2.id }]
}

resource "cloudru_evolution_compute_disk" "task2" {
  project_id  = var.project_id
  name        = "task2-disk"
  size        = 20
  zone_identifier = { name = "ru.AZ-2" }
  disk_type_identifier = { name = "SSD" }
  description = "Boot disk for task2"
  bootable    = true
  image_id    = "474c9e98-760f-4e54-aaa9-70024814f2b0"
  encrypted   = false
  readonly    = false
  shared      = false
}

resource "cloudru_evolution_compute_interface" "task2" {
  project_id  = var.project_id
  name        = "task2-interface"
  zone_identifier = { name = "ru.AZ-2" }
  description = "Network interface for task2"
  subnet_id   = "edc39aec-c01c-48a0-91ac-6f2653179394"

  interface_security_enabled = false
  type              = "INTERFACE_TYPE_REGULAR"
}
