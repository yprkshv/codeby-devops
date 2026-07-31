#!/bin/bash
set -euo pipefail

DB_NAME="cb_db"
DB_USER="cbadmin"
DB_PASS="passw0rd"
BACKUP_DIR="/opt/mysql_backup"
DATE=$(date +%Y%m%d_%H%M%S)
FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql.gz"
LOG="${BACKUP_DIR}/backup.log"

mysqldump -u"${DB_USER}" -p"${DB_PASS}" \
  --single-transaction --routines --triggers "${DB_NAME}" \
  | gzip > "${FILE}"
