#!/bin/bash
set -euo pipefail

STORE_HOST="192.168.56.11"
SHARED_DIR="/vagrant/shared/ssh_keys"
SSH_KEY_DEST="/home/vagrant/.ssh/id_backup"

echo "# копирование ключа SSH #"
mkdir -p /vagrant/.ssh
chmod 700 /vagrant/.ssh
cp "${SHARED_DIR}/id_backup" "${SSH_KEY_DEST}"
chmod 600 "${SSH_KEY_DEST}"
chown vagrant:vagrant "${SSH_KEY_DEST}"
echo "[server] ssh key copied to ${SSH_KEY_DEST}"
ssh-keyscan -H "${STORE_HOST}" >> /vagrant/.ssh/known_hosts 2>/dev/null || true

echo "# установка MySQL #"
apt-get update -y
apt-get install -y mysql-server rsync

systemctl enable --now mysql
