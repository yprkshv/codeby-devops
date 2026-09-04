output "vm_id" {
  description = "ID созданной ВМ"
  value       = cloudru_evolution_compute_vm.vm.id
}

output "selected_subnet_id" {
  description = "ID подсети, автоматически выбранной по указанной zone"
  value       = local.selected_subnet.id
}

output "selected_subnet_name" {
  description = "Имя подсети, автоматически выбранной по указанной zone"
  value       = local.selected_subnet.name
}

output "network_ip" {
  description = "Внутренний IP ВМ"
  value       = cloudru_evolution_compute_interface.vm.ip_address
}

output "external_ip" {
  description = "Публичный IP ВМ (если assign_external_ip = true)"
  value       = var.assign_external_ip ? cloudru_evolution_compute_interface.vm.external_ip.ip_address : null
}