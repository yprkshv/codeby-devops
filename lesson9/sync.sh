#!/bin/bash
set -euo pipefail

SRC="/opt/mysql_backup/"
DEST_USER="backupsync"
DEST_HOST="192.168.56.11"
DEST_DIR="/opt/store/mysql/"
SSH_KEY="/home/$(whoami)/.ssh/id_backup"
LOG="/opt/mysql_backup/sync.log"

rsync -avz --delete -e "ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no" \
  "${SRC}" "${DEST_USER}@${DEST_HOST}:${DEST_DIR}" >> "${LOG}" 2>&1

echo "$(date): sync done" >> "${LOG}"
