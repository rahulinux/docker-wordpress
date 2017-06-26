#!/usr/bin/env bash

# Make sure /backup/full exists
mkdir -p /backup/full

# Determine backup filename
TARGET_DIR="/backup/full/`date +%Y-%m-%d-%Hh%M`"
i=1
while [ -d "${TARGET_DIR}" ]; do
  TARGET_DIR="/backup/full/`date +%Y-%m-%d-%Hh%M`-$((i++))"
done

# Create backup
xtrabackup --backup --target-dir=${TARGET_DIR}
