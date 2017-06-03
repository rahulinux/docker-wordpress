#!/usr/bin/env bash

_DIR_=`dirname "$(readlink -f "$0")"`
source ${_DIR_}/config.sh

# Determine valid domain name
DOMAIN="$1"
DOMAIN_VALIDATE "${DOMAIN}"

# Check if directory exists and 'cd' there
cd ${DATA-./data}/html
if [ ! -d "${DOMAIN}" ]; then
  ERROR "Directory doesn't exist! [${DOMAIN}]"
fi

# Determine MySQL database name and user from wp-config.php
if [ ! -f "${DOMAIN}/wp-config.php" ]; then
  ERROR "WordPress configuration not found! [${DOMAIN}/wp-config.php]"
fi
DB_USER=`php -r "\`grep DB_USER ${DOMAIN}/wp-config.php\`; echo DB_USER;"`
DB_NAME=`php -r "\`grep DB_NAME ${DOMAIN}/wp-config.php\`; echo DB_NAME;"`

# Destroy MySQL database and user
MYSQL_DESTROY_DB_USER ${DB_NAME} ${DB_USER}

# Delete directory
WARNING "About to delete directory... [${DOMAIN}]"
rm -rf ${DOMAIN}

INFO "Restarting Docker container... [${APACHE2_CONTAINER}]"
docker restart ${APACHE2_CONTAINER} >> ${LOG_OUTPUT} 2>&1

INFO "Site destroyed successfully! [http://${DOMAIN}.${TLD}]"
