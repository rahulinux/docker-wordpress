#!/usr/bin/env bash

set -e
_DIR_=`dirname "$(readlink -f "$0")"`
_FILE_=`basename $0`

LOG_OUTPUT=/dev/null

# Change to Compose project directory
cd ${_DIR_}/..

# Load environment variables
source .env

# Helper functions (user interaction)
function CONFIRM {
    read -r -p "${1:-Are you sure?} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}
function INFO {
  echo -e "\e[1;94m[${_FILE_}]\e[0m ${1}"
}
function WARNING {
  echo -e "\e[1;33m[${_FILE_}]\e[0m ${1}"
  CONFIRM && return
  exit 1
}
function ERROR {
  echo -e "\e[1;31m[${_FILE_}]\e[0m ${1}"
  exit 1
}

# Helper function (domain)
function DOMAIN_VALIDATE {
  if [ -z "$1" ]; then
    ERROR "Domain is empty!"
    false;
  fi
  # If domain is alphanumeric, let it go
  if [ -z `echo $1 | tr -d "[:alnum:]"` ]; then
    true;
    return;
  fi
  # Strong domain validation
  if [ -z `echo "$1" | grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'` ]; then
    ERROR "Domain is invalid! [$1]"
    false;
  fi
}

function DOMAIN_SHORTEN {
  if [ -z "$1" ]; then
    ERROR "Can't shorten empty domain name"
  fi
  DOMAIN="$1"
  DOMAIN="${DOMAIN#www.}"
  DOMAIN="${DOMAIN#dev.}"
  DOMAIN="${DOMAIN%%.*}"
  echo "${DOMAIN}"
}

# Helper functions (MySQL)
function MYSQL_CREATE_DB_USER {
  DB_NAME="$1"
  DB_USER="$2"
  DB_PASSWORD="$3"

  if [ -z "${DB_NAME}" ]; then
    ERROR "Empty MySQL database name"
  fi
  if [ -z "${DB_USER}" ]; then
    ERROR "Empty MySQL database user"
  fi
  if [ -z "${DB_PASSWORD}" ]; then
    ERROR "Empty MySQL database password"
  fi

  INFO "Creating MySQL database and user... [${DB_NAME} / ${DB_USER}]"
  mysql -h ${MYSQL_HOST} -u root -p${MYSQL_ROOT_PASSWORD} -e  "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;" >> ${LOG_OUTPUT} 2>&1
  mysql -h ${MYSQL_HOST} -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL ON \`${DB_NAME}\`.* TO \`${DB_USER}\`@\`%\` IDENTIFIED BY '${DB_PASSWORD}';" >> ${LOG_OUTPUT} 2>&1
}

function MYSQL_DESTROY_DB_USER {
  DB_NAME="$1"
  DB_USER="$2"

  WARNING "Destroying MySQL database and user... [${DB_NAME} / ${DB_USER}]"
  mysql -h ${MYSQL_HOST} -u root -p${MYSQL_ROOT_PASSWORD} -e  "DROP DATABASE \`${DB_NAME}\`;" >> ${LOG_OUTPUT} 2>&1
  mysql -h ${MYSQL_HOST} -u root -p${MYSQL_ROOT_PASSWORD} -e "DROP USER \`${DB_USER}\`@\`%\`;" >> ${LOG_OUTPUT} 2>&1
}
