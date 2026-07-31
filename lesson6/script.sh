#!/bin/bash
set -euo pipefail

CURRENT_HOST="$(hostname)"

SERVER_KEY_SYNCED="/vagrant/.vagrant/machines/server/virtualbox/private_key"
SERVER_IP="192.168.56.10"
DEST_KEY="/home/vagrant/id_rsa_server"   # прямо в home, без .ssh

if [ "$CURRENT_HOST" == "server" ]; then
    echo ">>> server"

elif [ "$CURRENT_HOST" == "client" ]; then
    echo ">>> client"

    cp "$SERVER_KEY_SYNCED" "$DEST_KEY"
    chmod 600 "$DEST_KEY"
    chown vagrant:vagrant "$DEST_KEY"

    if ! grep -q " server$" /etc/hosts; then
        echo "$SERVER_IP server" >> /etc/hosts
    fi
fi
