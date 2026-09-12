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

# =============================================================================
# Модуль 1 — только данные: все подсети выбранной VPC
# =============================================================================
module "vpc_subnets" {
  source     = "./modules/subnet_info"
  project_id = var.project_id
  vpc_id     = var.vpc_id
  auth_key_id = var.auth_key_id
  auth_secret = var.auth_secret
}

# =============================================================================
# Модуль 2 — создаёт ВМ в выбранных VPC + Zone,
# subnet для неё выбирается автоматически по Zone (внутри модуля)
# =============================================================================
module "vm" {
  source     = "./modules/vm"
  project_id = var.project_id
  vpc_id     = var.vpc_id
  zone       = var.zone
  auth_key_id = var.auth_key_id
  auth_secret = var.auth_secret

  vm_name              = var.vm_name
  flavor               = var.flavor
  ssh_public_key_path  = var.ssh_public_key_path
  assign_external_ip   = true
}
