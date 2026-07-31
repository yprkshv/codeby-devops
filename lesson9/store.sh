#!/bin/bash
set -euo pipefail

USER_NAME="backupsync"
DEST_DIR="/opt/store/mysql"
HOME_DIR="/home/${USER_NAME}"
SSH_DIR="${HOME_DIR}/.ssh"
KEY_PATH="${SSH_DIR}/id_backup"
SHARED_DIR="/vagrant/shared/ssh_keys"

echo "# установка rsynq и создание пользователя #"
apt-get update -y
apt-get install -y rsync
useradd -m -s /bin/bash "${USER_NAME}"

echo "# создание каталогов #"
mkdir -p "${DEST_DIR}"
chown "${USER_NAME}:${USER_NAME}" "${DEST_DIR}"
chmod 750 "${DEST_DIR}"
mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"
chown "${USER_NAME}:${USER_NAME}" "${SSH_DIR}"

echo "# создание ключей #"
sudo -u "${USER_NAME}" ssh-keygen -t ed25519 -f "${KEY_PATH}" -N "" -C "backupsync@store"
touch "${SSH_DIR}/authorized_keys"
if ! grep -qf "${KEY_PATH}.pub" "${SSH_DIR}/authorized_keys" 2>/dev/null; then
    cat "${KEY_PATH}.pub" >> "${SSH_DIR}/authorized_keys"
fi
chmod 600 "${SSH_DIR}/authorized_keys"
chown "${USER_NAME}:${USER_NAME}" "${SSH_DIR}/authorized_keys"

echo "# копирование ключей для server #"
mkdir -p "${SHARED_DIR}"
cp "${KEY_PATH}"     "${SHARED_DIR}/id_backup"
cp "${KEY_PATH}.pub" "${SHARED_DIR}/id_backup.pub"
