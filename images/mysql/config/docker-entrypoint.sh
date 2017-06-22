#!/bin/bash

function START_MYSQL_SERVER {
  mysqld_safe > /dev/null 2>&1 &
  RET=1
  while [[ $RET -ne 0 ]]; do
    sleep 1
    mysql -e "status" > /dev/null 2>&1
    RET=$?
  done
}

function STOP_MYSQL_SERVER {
  mysqladmin shutdown > /dev/null 2>&1
}

# Install MySQL database
if [ ! -d /var/lib/mysql/mysql ]; then

  echo "=> Installing MySQL database..."
  mysqld --initialize-insecure > /dev/null 2>&1

  START_MYSQL_SERVER

  # Generate password if necessary
  PASSWORD=${MYSQL_ROOT_PASSWORD:-$(date | md5sum | head -c8)}

  # Create MySQL root user
  mysql -u root -e "CREATE USER 'root'@'%' IDENTIFIED BY '${PASSWORD}'" > /dev/null 2>&1
  mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION" > /dev/null 2>&1
  mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION" > /dev/null 2>&1
  echo "=> MySQL user 'root' created with password '${PASSWORD}'"

  STOP_MYSQL_SERVER

else
  echo "=> MySQL already installed in /var/lib/mysql"
fi

# Configure MySQL replication
if [ "${MYSQL_REPLICATION}" == "master" ]; then

  # Create /etc/mysql/conf.d/master.cnf
  echo "=> Configuring replication MASTER... [server-id=${MYSQL_SERVER_ID-1}]"
  cat > /etc/mysql/conf.d/master.cnf << EOL
[mysqld]
server-id=${MYSQL_SERVER_ID-1}
binlog_format=ROW
log-bin
EOL

  START_MYSQL_SERVER

  # Create replication user
  mysql -u root -e "GRANT REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO ${REPL_USER-repl}@'%' IDENTIFIED BY '${REPL_PASSWORD-changeme}';" > /dev/null 2>&1
  echo "=> MySQL user '${REPL_USER-repl}' created with password '${REPL_PASSWORD-changeme}'"

  STOP_MYSQL_SERVER

elif [ "${MYSQL_REPLICATION}" == "slave" ]; then

  # Create /etc/mysql/conf.d/slave.cnf
  echo "=> Configuring replication SLAVE... [server-id=${MYSQL_SERVER_ID-2}]"
  cat > /etc/mysql/conf.d/master.cnf << EOL
[mysqld]
server-id=${MYSQL_SERVER_ID-2}
EOL

  START_MYSQL_SERVER

  # Wait for master server
  echo "=> Waiting for master server..."
  RET=1
  while [[ $RET -ne 0 ]]; do
    sleep 1
    mysql -u ${REPL_USER-repl} -p${REPL_PASSWORD-changeme} -h ${MASTER_HOST-master} -e "status" > /dev/null 2>&1
    RET=$?
  done

  # Determine MASTER_LOG_FILE and MASTER_LOG_POS from master host
  MASTER_LOG_FILE=`mysql -u ${REPL_USER-repl} -p${REPL_PASSWORD-changeme} -h ${MASTER_HOST-master} -ANe "SHOW MASTER STATUS;" 2> /dev/null  | awk '{print $1}'`
  MASTER_LOG_POS=`mysql -u ${REPL_USER-repl} -p${REPL_PASSWORD-changeme} -h ${MASTER_HOST-master} -ANe "SHOW MASTER STATUS;" 2> /dev/null  | awk '{print $2}'`

  # Start repliation
  echo "=> Starting replication SLAVE... [${MASTER_LOG_FILE} / ${MASTER_LOG_FILE}]"
  mysql -e "CHANGE MASTER TO MASTER_HOST='${MASTER_HOST-master}', MASTER_USER='${REPL_USER-repl}', MASTER_PASSWORD='${REPL_PASSWORD-changeme}', MASTER_LOG_FILE='${MASTER_LOG_FILE}', MASTER_LOG_POS=${MASTER_LOG_POS};" >> /dev/null 2>&1
  mysql -e "START SLAVE;"

  STOP_MYSQL_SERVER

fi

echo "=> Starting MySQL server..."
exec mysqld_safe
