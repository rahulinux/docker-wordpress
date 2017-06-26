#!/usr/bin/env bash

# Make sure backup exists
TARGET_DIR="/backup/full/$1"
if [ ! -f "${TARGET_DIR}/xtrabackup_info" ]; then
  echo "ERROR: Backup does not exist! [${TARGET_DIR}]"
  exit 1
fi

# Create working copy
WORK_DIR="/tmp/$1"
if [ -d "${WORK_DIR}" ]; then
  rm -rf ${WORK_DIR}
fi
cp -R ${TARGET_DIR}/ /tmp/

# Prepare backup
xtrabackup --prepare --target-dir=${WORK_DIR}

# Restore backup
mysqladmin shutdown
rm -rf /var/lib/mysql/*
xtrabackup --copy-back --target-dir=${WORK_DIR}
chown -R mysql:mysql /var/lib/mysql
supervisorctl start mysqld

# Delete working copy
rm -rf ${WORK_DIR}
