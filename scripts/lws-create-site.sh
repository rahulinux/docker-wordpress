#!/usr/bin/env bash

_DIR_=`dirname "$(readlink -f "$0")"`
source ${_DIR_}/config.sh

# Determine valid domain name
DOMAIN="$1"
DOMAIN_VALIDATE "${DOMAIN}"

# Create directory and 'cd' there
cd ${DATA-./data}/html
if [ ! -d "${DOMAIN}" ]; then
  INFO "Creating directory... [${DOMAIN}]"
  mkdir -p ${DOMAIN}
else
  WARNING "Directory already exists! [${DOMAIN}]"
fi
cd ${DOMAIN}

INFO "Restarting Docker container... [${APACHE2_CONTAINER}]"
docker restart ${APACHE2_CONTAINER} >> ${LOG_OUTPUT} 2>&1

INFO "Preparing WordPress source tree..."
wp core download --force >> ${LOG_OUTPUT} 2>&1
rm -rf wp-content/plugins/hello.php wp-content/plugins/akismet

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

# Determine database name, user and password
DOMAIN_SHORT=`DOMAIN_SHORTEN ${DOMAIN}`
DB_NAME="wp_${DOMAIN_SHORT}"
DB_USER="wp_${DOMAIN_SHORT}"
DB_PASSWORD=`date | md5sum | head -c12`

# Create database and user
MYSQL_CREATE_DB_USER ${DB_NAME} ${DB_USER} ${DB_PASSWORD}

# Configure WordPress database
INFO "Configuring WordPress database..."
wp core config --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASSWORD} --dbhost=${MYSQL_HOST} >> ${LOG_OUTPUT} 2>&1

INFO "Site created successfully! [http://${DOMAIN}.${TLD}]"
