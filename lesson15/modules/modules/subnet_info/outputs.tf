output "subnets" {
  description = "Список всех подсетей выбранной VPC (полные объекты датасорса)"
  value       = local.vpc_subnets
}

output "subnet_ids" {
  description = "Только ID подсетей выбранной VPC"
  value       = [for s in local.vpc_subnets : s.id]
}

output "subnets_by_zone" {
  description = "Карта: имя зоны -> список подсетей в этой зоне (для автоматического выбора subnet по zone)"
  value = {
    for zone_name in distinct([for s in local.vpc_subnets : s.zone.name]) :
    zone_name => [for s in local.vpc_subnets : s if s.zone.name == zone_name]
  }
}
