#!/bin/bash

# Configure MySQL
if [ ! -d /var/lib/mysql/mysql ]; then

  # Install MySQL database
  echo "=> Installing MySQL database..."
  mysqld --initialize-insecure > /dev/null 2>&1

  # Start MySQL server
  mysqld_safe > /dev/null 2>&1 &
  RET=1
  while [[ $RET -ne 0 ]]; do
    sleep 1
    mysql -u root -e "status" > /dev/null 2>&1
    RET=$?
  done

  # Generate password if necessary
  PASSWORD=${MYSQL_ROOT_PASSWORD:-$(date | md5sum | head -c8)}

  # Create MySQL root user
  echo "=> Creating MySQL 'root' user..."
  mysql -u root -e "CREATE USER 'root'@'%' IDENTIFIED BY '${PASSWORD}'" > /dev/null 2>&1
  mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION" > /dev/null 2>&1
  mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION" > /dev/null 2>&1
  echo "========================================================="
  echo "=> MySQL user 'root' created with password '$PASSWORD' <="
  echo "========================================================="

  # Stop MySQL server
  mysqladmin -u root shutdown > /dev/null 2>&1

else
  echo "=> MySQL already installed in /var/lib/mysql"
fi

exec /usr/bin/mysqld_safe
