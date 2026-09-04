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
# Data sources
# =============================================================================
data "cloudru_evolution_compute_image_collection" "ubuntu" {
  project_id = var.project_id
  page_size  = 100
}

locals {
  ubuntu_image_id = [
    for img in data.cloudru_evolution_compute_image_collection.ubuntu.images :
    img.id if img.name == "ubuntu-22.04"
  ][0]

  ssh_public_key = file(var.ssh_public_key_path)
}

# =============================================================================
# Subnets
# =============================================================================
resource "cloudru_evolution_compute_subnet" "public" {
  project_id     = var.project_id
  name           = "public"
  description    = "Public subnet for resources with external access"
  zone_identifier = { name = var.zone }
  subnet_address = "10.0.1.0/24"
  routed_network = true
  default        = false
  vpc_id         = var.vpc_id
  dns_servers    = { value = ["8.8.4.4", "8.8.8.8"] }
}

resource "cloudru_evolution_compute_subnet" "private" {
  project_id     = var.project_id
  name           = "private"
  description    = "Private subnet for internal resources"
  zone_identifier = { name = var.zone }
  subnet_address = "10.0.2.0/24"
  routed_network = true
  default        = false
  vpc_id         = var.vpc_id
  dns_servers    = { value = ["8.8.4.4", "8.8.8.8"] }
}

# =============================================================================
# PUBLIC VM — Security Group
# =============================================================================
resource "cloudru_evolution_compute_security_group" "public_vm" {
  project_id  = var.project_id
  name        = "public-vm-sg"
  zone_identifier = { name = var.zone }
  description = "Security group for public VM: SSH, HTTP, HTTPS"
}

resource "cloudru_evolution_compute_security_group_rule" "public_ssh" {
  security_group_id = cloudru_evolution_compute_security_group.public_vm.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "22:22"
  description       = "SSH access from my IP"
  remote_ip_prefix  = var.my_ip_cidr
}

resource "cloudru_evolution_compute_security_group_rule" "public_http" {
  security_group_id = cloudru_evolution_compute_security_group.public_vm.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "80:80"
  description       = "HTTP access from everywhere"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "cloudru_evolution_compute_security_group_rule" "public_https" {
  security_group_id = cloudru_evolution_compute_security_group.public_vm.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "443:443"
  description       = "HTTPS access from everywhere"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "cloudru_evolution_compute_security_group_rule" "public_egress_tcp" {
  security_group_id = cloudru_evolution_compute_security_group.public_vm.id
  direction         = "TRAFFIC_DIRECTION_EGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "1:65535"
  description       = "Allow all outbound TCP"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "cloudru_evolution_compute_security_group_rule" "public_egress_udp" {
  security_group_id = cloudru_evolution_compute_security_group.public_vm.id
  direction         = "TRAFFIC_DIRECTION_EGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_UDP"
  port_range        = "1:65535"
  description       = "Allow all outbound UDP"
  remote_ip_prefix  = "0.0.0.0/0"
}

# =============================================================================
# PRIVATE VM — Security Group
# =============================================================================
resource "cloudru_evolution_compute_security_group" "private_vm" {
  project_id  = var.project_id
  name        = "private-vm-sg"
  zone_identifier = { name = var.zone }
  description = "Security group for private VM: SSH, 8080"
}

resource "cloudru_evolution_compute_security_group_rule" "private_ssh" {
  security_group_id = cloudru_evolution_compute_security_group.private_vm.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "22:22"
  description       = "SSH access from my IP"
  remote_ip_prefix  = var.my_ip_cidr
}

resource "cloudru_evolution_compute_security_group_rule" "private_8080" {
  security_group_id = cloudru_evolution_compute_security_group.private_vm.id
  direction         = "TRAFFIC_DIRECTION_INGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "8080:8080"
  description       = "Port 8080 from public subnet"
  remote_ip_prefix  = "10.0.1.0/24"
}

resource "cloudru_evolution_compute_security_group_rule" "private_egress_tcp" {
  security_group_id = cloudru_evolution_compute_security_group.private_vm.id
  direction         = "TRAFFIC_DIRECTION_EGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_TCP"
  port_range        = "1:65535"
  description       = "Allow all outbound TCP"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "cloudru_evolution_compute_security_group_rule" "private_egress_udp" {
  security_group_id = cloudru_evolution_compute_security_group.private_vm.id
  direction         = "TRAFFIC_DIRECTION_EGRESS"
  ether_type        = "ETHER_TYPE_IPV4"
  ip_protocol       = "IP_PROTOCOL_UDP"
  port_range        = "1:65535"
  description       = "Allow all outbound UDP"
  remote_ip_prefix  = "0.0.0.0/0"
}

# =============================================================================
# PUBLIC VM — Disk
# =============================================================================
resource "cloudru_evolution_compute_disk" "public_vm" {
  project_id  = var.project_id
  name        = "public-vm-disk"
  size        = var.disk_size
  zone_identifier = { name = var.zone }
  disk_type_identifier = { name = var.disk_type }
  description = "Boot disk for public VM"
  bootable    = true
  image_id    = local.ubuntu_image_id
  encrypted   = false
  readonly    = false
  shared      = false
}

# =============================================================================
# PUBLIC VM — Network Interface (с публичным IP)
# =============================================================================
resource "cloudru_evolution_compute_interface" "public_vm" {
  project_id  = var.project_id
  name        = "public-vm-interface"
  zone_identifier = { name = var.zone }
  description = "Network interface for public VM"
  subnet_id   = cloudru_evolution_compute_subnet.public.id

  interface_security_enabled = true
  security_groups_identifiers = {
    value = [{ id = cloudru_evolution_compute_security_group.public_vm.id }]
  }

  external_ip_specs = { new_external_ip = true }
  type              = "INTERFACE_TYPE_REGULAR"
}

# =============================================================================
# PUBLIC VM — Virtual Machine
# =============================================================================
resource "cloudru_evolution_compute_vm" "public" {
  project_id  = var.project_id
  name        = "public-vm"
  zone_identifier = { name = var.zone }
  flavor_identifier = { name = var.flavor }
  description = "Public VM with Nginx"

  disk_identifiers = [{ disk_id = cloudru_evolution_compute_disk.public_vm.id }]
  network_interfaces = [{ interface_id = cloudru_evolution_compute_interface.public_vm.id }]

  cloud_init_userdata = base64encode(templatefile("${path.module}/cloud-init.yaml.tpl", {
    ssh_public_key = local.ssh_public_key
    vm_name        = "public-vm"
  }))
  provisioner "file" {
    source        = "${path.module}/install-nginx.sh"
    destination   = "/tmp/install-nginx.sh"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = cloudru_evolution_compute_interface.public_vm.external_ip.ip_address
      timeout     = "10m"
    }
  }
  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/install-nginx.sh", "sudo /tmp/install-nginx.sh"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = cloudru_evolution_compute_interface.public_vm.external_ip.ip_address
      timeout     = "10m"
    }
  }
}
# =============================================================================
# PRIVATE VM — Disk
# =============================================================================
resource "cloudru_evolution_compute_disk" "private_vm" {
  project_id  = var.project_id
  name        = "private-vm-disk"
  size        = var.disk_size
  zone_identifier = { name = var.zone }
  disk_type_identifier = { name = var.disk_type }
  description = "Boot disk for private VM"
  bootable    = true
  image_id    = local.ubuntu_image_id
  encrypted   = false
  readonly    = false
  shared      = false
}

# =============================================================================
# PRIVATE VM — Network Interface (без публичного IP)
# =============================================================================
resource "cloudru_evolution_compute_interface" "private_vm" {
  project_id  = var.project_id
  name        = "private-vm-interface"
  zone_identifier = { name = var.zone }
  description = "Network interface for private VM"
  subnet_id   = cloudru_evolution_compute_subnet.private.id

  interface_security_enabled = true
  security_groups_identifiers = {
    value = [{ id = cloudru_evolution_compute_security_group.private_vm.id }]
  }
  external_ip_specs = { new_external_ip = true }
  type = "INTERFACE_TYPE_REGULAR"
}

# =============================================================================
# PRIVATE VM — Virtual Machine
# =============================================================================
resource "cloudru_evolution_compute_vm" "private" {
  project_id  = var.project_id
  name        = "private-vm"
  zone_identifier = { name = var.zone }
  flavor_identifier = { name = var.flavor }
  description = "Private VM with Nginx on 8080"

  disk_identifiers = [{ disk_id = cloudru_evolution_compute_disk.private_vm.id }]
  network_interfaces = [{ interface_id = cloudru_evolution_compute_interface.private_vm.id }]

  cloud_init_userdata = base64encode(templatefile("${path.module}/cloud-init.yaml.tpl", {
    ssh_public_key = local.ssh_public_key
    vm_name        = "private-vm"
  }))

  provisioner "file" {
    source        = "${path.module}/install-nginx-private.sh"
    destination   = "/tmp/install-nginx-private.sh"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      #host        = cloudru_evolution_compute_interface.private_vm.external_ip.ip_address
      host                = cloudru_evolution_compute_interface.private_vm.ip_address
      bastion_host        = cloudru_evolution_compute_interface.public_vm.external_ip.ip_address
      bastion_user        = "ubuntu"
      bastion_private_key = file(var.ssh_private_key_path)
      timeout     = "10m"
    }
  }
  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/install-nginx-private.sh", "sudo /tmp/install-nginx-private.sh"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      #host        = cloudru_evolution_compute_interface.private_vm.external_ip.ip_address
      host                = cloudru_evolution_compute_interface.private_vm.ip_address
      bastion_host        = cloudru_evolution_compute_interface.public_vm.external_ip.ip_address
      bastion_user        = "ubuntu"
      bastion_private_key = file(var.ssh_private_key_path)
      timeout     = "10m"
    }
  }
}


# =============================================================================
# Outputs
# =============================================================================
output "public_subnet_id" {
  description = "ID public подсети"
  value       = cloudru_evolution_compute_subnet.public.id
}
output "private_subnet_id" {
  description = "ID private подсети"
  value       = cloudru_evolution_compute_subnet.private.id
}
output "public_vm_external_ip" {
  description = "Публичный IP public-vm"
  value       = cloudru_evolution_compute_interface.public_vm.external_ip.ip_address
}
output "private_vm_internal_ip" {
  description = "Внутренний IP private-vm"
  value       = cloudru_evolution_compute_interface.private_vm.ip_address
}