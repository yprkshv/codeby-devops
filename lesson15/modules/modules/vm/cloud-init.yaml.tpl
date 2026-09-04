#cloud-config
users:
  - name: ubuntu
    ssh-authorized-keys:
      - ${ssh_public_key}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    lock_passwd: true
hostname: ${vm_name}
manage_etc_hosts: true
