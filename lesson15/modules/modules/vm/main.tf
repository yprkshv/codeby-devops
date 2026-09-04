# =============================================================================
# Модуль создания ВМ: выбранные VPC + Zone, subnet выбирается автоматически
# =============================================================================
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

module "subnets" {
  source     = "../subnet_info"
  project_id = var.project_id
  vpc_id     = var.vpc_id
  auth_key_id = var.auth_key_id
  auth_secret = var.auth_secret
}

locals {
  # Все подсети указанной VPC, лежащие в указанной Zone
  subnets_in_zone = [
    for s in module.subnets.subnets : s if s.zone.name == var.zone
  ]

  # Если в зоне несколько подсетей — детерминированно берём подсеть с "меньшим" id,
  # чтобы результат не менялся между прогонами terraform plan/apply.
  subnets_in_zone_sorted = [
    for id in sort([for s in local.subnets_in_zone : s.id]) :
    [for s in local.subnets_in_zone : s if s.id == id][0]
  ]

  selected_subnet = length(local.subnets_in_zone_sorted) > 0 ? local.subnets_in_zone_sorted[0] : null
}

# Явная проверка: без подходящей подсети создавать ВМ нет смысла — падаем с понятной ошибкой
resource "terraform_data" "assert_subnet_found" {
  lifecycle {
    precondition {
      condition     = local.selected_subnet != null
      error_message = "В VPC '${var.vpc_id}' не найдено ни одной подсети в зоне '${var.zone}'. Проверьте vpc_id и zone."
    }
  }
}

data "cloudru_evolution_compute_image_collection" "images" {
  project_id = var.project_id
  page_size  = 100
}

locals {
  image_id = [
    for img in data.cloudru_evolution_compute_image_collection.images.images :
    img.id if img.name == var.image_name
  ][0]

  ssh_public_key = file(var.ssh_public_key_path)
}

resource "cloudru_evolution_compute_disk" "vm" {
  project_id            = var.project_id
  name                  = "${var.vm_name}-disk"
  size                  = var.disk_size
  zone_identifier       = { name = var.zone }
  disk_type_identifier  = { name = var.disk_type }
  description           = "Boot disk for ${var.vm_name}"
  bootable              = true
  image_id              = local.image_id
  encrypted             = false
  readonly              = false
  shared                = false
}

resource "cloudru_evolution_compute_interface" "vm" {
  project_id      = var.project_id
  name            = "${var.vm_name}-interface"
  zone_identifier = { name = var.zone }
  description     = "Network interface for ${var.vm_name}"

  # Ключевая часть задания: subnet_id берётся не от пользователя,
  # а вычисляется автоматически по совпадению zone у подсети и у ВМ
  subnet_id = local.selected_subnet.id

  interface_security_enabled = true
  security_groups_identifiers = {
    value = [for sg_id in var.security_group_ids : { id = sg_id }]
  }

  external_ip_specs = var.assign_external_ip ? { new_external_ip = true } : null
  type              = "INTERFACE_TYPE_REGULAR"

  depends_on = [terraform_data.assert_subnet_found]
}

resource "cloudru_evolution_compute_vm" "vm" {
  project_id        = var.project_id
  name              = var.vm_name
  zone_identifier   = { name = var.zone }
  flavor_identifier = { name = var.flavor }
  description       = "Created by vm module, subnet auto-selected by zone"

  disk_identifiers    = [{ disk_id = cloudru_evolution_compute_disk.vm.id }]
  network_interfaces  = [{ interface_id = cloudru_evolution_compute_interface.vm.id }]

  cloud_init_userdata = base64encode(templatefile("${path.module}/cloud-init.yaml.tpl", {
    ssh_public_key = local.ssh_public_key
    vm_name        = var.vm_name
  }))
}

data "cloudru_evolution_compute_flavor_collection" "debug" {
  project_id = var.project_id
  page_size  = 200
}

output "available_flavors_debug" {
  value = [for f in data.cloudru_evolution_compute_flavor_collection.debug.flavors : f.name]
}