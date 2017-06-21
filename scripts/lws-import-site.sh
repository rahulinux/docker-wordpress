#!/usr/bin/env bash

_DIR_=`dirname "$(readlink -f "$0")"`
source ${_DIR_}/config.sh

# Determine remote host
REMOTE_HOST="$1"

# Determine remote directory
REMOTE_DIR="$2"

# Validate remote host and directory
INFO "Validating remote host and directory..."
ssh ${REMOTE_HOST} "cd ${REMOTE_DIR} && [ -f wp-config.php ]" 2>/dev/null >> ${LOG_OUTPUT} 2>&1
if [ $? != 0 ]; then
  ERROR "Invalid remote host or directory."
fi

# Determine and validate domain name
SITE_URL=`ssh ${REMOTE_HOST} "cd ${REMOTE_DIR} && wp --allow-root option get siteurl" 2>/dev/null`
DOMAIN=${SITE_URL##*/}
DOMAIN_VALIDATE "${DOMAIN}"

# Validate domain name
if [ -z "${DOMAIN}" ]; then
  ERROR "Could not determine domain name."
fi

# Confirm user action
WARNING "Importing WordPress site... [${SITE_URL}]"

# Shorten domain name
DOMAIN_SHORT=`DOMAIN_SHORTEN ${DOMAIN}`
CONFIRM "Shorten domain name? [${DOMAIN_SHORT}]" && DOMAIN=${DOMAIN_SHORT}

# Create directory and 'cd' there
cd ${DATA-./data}/html
if [ ! -d "${DOMAIN}" ]; then
  INFO "Creating directory... [${DOMAIN}]"
  mkdir -p ${DOMAIN}
  INFO "Restarting Docker container... [${APACHE2_CONTAINER}]"
  docker restart ${APACHE2_CONTAINER} >> ${LOG_OUTPUT} 2>&1
else
  INFO "Directory already exists! [${DOMAIN}]"
fi
cd ${DOMAIN}

# Synchronize files
INFO "Synchronizing files..."
EXCLUDE_FILES="cgi-bin error_log .idea .well-known"
rsync -ave "ssh" $REMOTE_HOST:$REMOTE_DIR/ ./ --exclude "${EXCLUDE_FILES}" >> ${LOG_OUTPUT} 2>&1

# Prepare and initialize Git repository
if [ -f .gitignore ]; then
  INFO "Git repository already prepared! [.gitignore]"
else
  INFO "Preparing Git repository... [.gitignore]"
  cp ${_DIR_}/templates/gitignore .gitignore
fi
if [ -d .git ]; then
  INFO "Git repository already initialized! [.git]"
else
  INFO "Initializing Git repository..."
  git init >> ${LOG_OUTPUT} 2>&1
  git add -A >> ${LOG_OUTPUT} 2>&1
  git commit -am "Initial commit" >> ${LOG_OUTPUT} 2>&1
fi

# Determine database name, user and password from wp-config.php
DB_USER=`php -r "\`grep DB_USER wp-config.php\`; echo DB_USER;"`
DB_NAME=`php -r "\`grep DB_NAME wp-config.php\`; echo DB_NAME;"`
DB_PASSWORD=`php -r "\`grep DB_PASSWORD wp-config.php\`; echo DB_PASSWORD;"`

# Determine database name, user and password
#DB_NAME="wp_${DOMAIN_SHORT}"
#DB_USER="wp_${DOMAIN_SHORT}"
#DB_PASSWORD=`date | md5sum | head -c12`

# Create database and user
MYSQL_CREATE_DB_USER ${DB_NAME} ${DB_USER} ${DB_PASSWORD}

# Configure WordPress database
INFO "Configuring WordPress database..."
chmod 644 wp-config.php
wp core config --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASSWORD} --dbhost=${MYSQL_HOST} --force >> ${LOG_OUTPUT} 2>&1

# Reset database
WARNING "About to reset database [${DB_NAME}]"
wp db reset --yes >> ${LOG_OUTPUT} 2>&1

# Synchronize database
INFO "Synchronizing database..."
ssh ${REMOTE_HOST} "cd ${REMOTE_DIR} && wp --allow-root db export -" 2>/dev/null | wp db import - >> ${LOG_OUTPUT} 2>&1

# Replace site URL
INFO "Replacing ${SITE_URL} with http://${DOMAIN}.${TLD}"
wp search-replace "${SITE_URL}" "http://${DOMAIN}.${TLD}" >> ${LOG_OUTPUT} 2>&1

# Deactivate unwanted plugins
INFO "Deactivating plugins..."
UNWANTED_PLUGINS="ithemes-security-pro \
  sendgrid-email-delivery-simplified \
  w3-total-cache \
  wordfence \
  wordpress-https \
  wp-force-ssl"
wp plugin deactivate ${PLUGIN} >> ${LOG_OUTPUT} 2>&1 || true

echo
INFO "WordPres site imported successfully! [http://${DOMAIN}.${TLD}]"
