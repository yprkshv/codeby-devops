#!/bin/bash
set -euo pipefail

DOMAIN="codebyles8.local"
SERVER_IP="192.168.56.10"
CERT_SRC="/vagrant/${DOMAIN}.crt"

echo "# Установка ca-certificates #"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ca-certificates curl

echo "# добавление в хосты #"
if ! grep -q "[[:space:]]${DOMAIN}\b" /etc/hosts; then
    echo "${SERVER_IP} ${DOMAIN} www.${DOMAIN}" >> /etc/hosts
fi

echo "# копирование сертификата #"
sudo cp "$CERT_SRC" "/usr/local/share/ca-certificates/${DOMAIN}.crt"
sudo update-ca-certificates
