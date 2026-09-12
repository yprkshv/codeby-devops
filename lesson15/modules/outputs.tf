output "all_subnets_in_vpc" {
  description = "Все подсети выбранной VPC (из модуля данных)"
  value       = module.vpc_subnets.subnets
}

output "subnets_grouped_by_zone" {
  description = "Подсети выбранной VPC, сгруппированные по zone"
  value       = module.vpc_subnets.subnets_by_zone
}

output "vm_id" {
  value = module.vm.vm_id
}

output "vm_auto_selected_subnet" {
  description = "Какую подсеть модуль vm выбрал автоматически для указанной zone"
  value       = module.vm.selected_subnet_name
}

output "vm_network_ip" {
  value = module.vm.network_ip
}

output "vm_external_ip" {
  value = module.vm.external_ip
}

output "debug_available_flavors" {
  value = module.vm.available_flavors_debug
}