#!/usr/bin/env bash

_DIR_=`dirname "$(readlink -f "$0")"`
source ${_DIR_}/config.sh

DOMAIN="$1"
if [ -z "${DOMAIN}" ]; then
  ERROR "Please specify domain"
fi

cd ${DATA-./data}/html
INFO "Creating directory ${DOMAIN}..."
mkdir -p ${DOMAIN}
cd ${DOMAIN}

INFO "Restarting ${APACHE2_CONTAINER} Docker container..."
docker restart ${APACHE2_CONTAINER} >> ${LOG_OUTPUT} 2>&1

INFO "Preparing WordPress source tree..."
wp core download >> ${LOG_OUTPUT} 2>&1
rm -rf wp-content/plugins/hello.php wp-content/plugins/akismet

if [ ! -f .gitignore ]; then
  INFO "Preparing Git repository..."
  wget http://pastebin.com/raw/nUJuzeWm -O .gitignore >> ${LOG_OUTPUT} 2>&1
fi
if [ ! -d .git ]; then
  INFO "Initializing Git repository..."
  git init >> ${LOG_OUTPUT} 2>&1
  git add -A >> ${LOG_OUTPUT} 2>&1
  git commit -am "Initial commit" >> ${LOG_OUTPUT} 2>&1
fi

# Determine database name, user and password
SITE_NAME="${SITE_DOMAIN%.*}"
DB_USER="wp_$SITE_NAME"
DB_NAME="wp_$SITE_NAME"
DB_PASSWORD=`date | md5sum | head -c12`

# Create database and user
INFO "Creating database $DB_NAME and user $DB_USER..."
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e  "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;" >> /dev/null 2>&1
mysql -h $MYSQL_HOST -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL ON \`$DB_NAME\`.* TO \`$DB_USER\`@\`%\` IDENTIFIED BY '$DB_PASSWORD';" >> /dev/null 2>&1

# Configure WordPress database
echo "Configuring WordPress database..."
wp core config --dbhost=$MYSQL_HOST --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD >> /dev/null 2>&1

echo "Done! Visit http://$SITE_DOMAIN.$TLD"
