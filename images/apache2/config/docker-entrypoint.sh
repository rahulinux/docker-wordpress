#!/bin/bash
set -e

# Load Apache environment variables
. /etc/apache2/envvars

# Remove existing PID file
if [ -f /var/run/apache2/apache2.pid ]; then
  rm -f /var/run/apache2/apache2.pid
fi

# Generate vhosts automatically
echo "=> Generating vhosts..."
echo "# Generated automatically" > /etc/apache2/sites-available/vhosts.conf
cd /var/www/html
for VHOST in * ; do
  if [ -d ${VHOST} ] ; then
    echo "\
<VirtualHost *:80>
  ServerName $VHOST
  ServerAlias $VHOST.${TLD-$HOSTNAME}
  DocumentRoot /var/www/html/$VHOST
  <Directory /var/www/html/$VHOST/>
    Options +FollowSymLinks -Indexes
    AllowOverride all
    Require all granted
  </Directory>
</VirtualHost>
" | tee -a /etc/apache2/sites-available/vhosts.conf >> /dev/null
  fi
done

# Enable vhosts
if [ ! -f /etc/apache2/sites-enabled/vhosts.conf ]; then
  a2ensite vhosts >> /dev/null
fi

# Configure Xdebug
if [ "${XDEBUG_ENABLE}" == "yes" ]; then
  echo "=> Enabling Xdebug..."
  phpenmod xdebug
else
  echo "=> Disabling Xdebug..."
  phpdismod xdebug
fi

# Configure SMTP relay
if [ ! -z "${SMTP_RELAY}" ]; then
  echo "=> Enabling SMTP relay... [${SMTP_RELAY}]"
  phpenmod ssmtp
  sed -i "s@mailhub.*=.*@mailhub=${SMTP_RELAY}@g" /etc/ssmtp/ssmtp.conf
else
  echo "=> Disabling SMTP relay..."
  phpdismod ssmtp
fi

exec apache2 -DFOREGROUND "$@"
