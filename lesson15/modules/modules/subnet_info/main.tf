# =============================================================================
# Модуль только для данных: получает информацию обо всех subnet в выбранной VPC
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

data "cloudru_evolution_compute_subnet_collection" "all" {
  project_id = var.project_id
  page_size  = 200
}

locals {
  # Датасорс отдаёт подсети всего проекта — фильтруем на стороне Terraform
  # по нужной VPC, т.к. серверный CEL-фильтр по vpc_id не документирован
  # как гарантированно поддерживаемый.
  vpc_subnets = [
    for s in data.cloudru_evolution_compute_subnet_collection.all.subnets :
    s if s.vpc_id == var.vpc_id
  ]
}
