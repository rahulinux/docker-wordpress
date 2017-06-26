#!/usr/bin/env bash

# Make sure /backup/incremental exists
mkdir -p /backup/incremental

# Make sure base backup exists
if [ ! -f "/backup/incremental/0base/xtrabackup_info.qp" ]; then
  xtrabackup --backup --compress --target-dir=/backup/incremental/0base
  exit 0
fi

# Determine backup filename
TARGET_DIR="/backup/incremental/`date +%Y-%m-%d-%Hh%M`"
i=1
while [ -d "${TARGET_DIR}" ]; do
  TARGET_DIR="/backup/incremental/`date +%Y-%m-%d-%Hh%M`-$((i++))"
done

# Create incremental backup
LAST_DIR=`ls -1 /backup/incremental/ | tail -n 1`
xtrabackup --backup --compress --incremental-basedir=/backup/incremental/${LAST_DIR} --target-dir=${TARGET_DIR}
