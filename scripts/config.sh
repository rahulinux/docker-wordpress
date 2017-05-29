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
  echo -e "\e[1;32m[${_FILE_}]\e[0m ${1}"
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
function DOMAIN_EXTRACT_NAME {
  if [ -z "$1" ]; then
    ERROR "Can't extract empty domain name"
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
    ERROR "Empty database name"
  fi
  if [ -z "${DB_USER}" ]; then
    ERROR "Empty database user"
  fi
  if [ -z "${DB_PASSWORD}" ]; then
    ERROR "Empty database password"
  fi

  INFO "Creating database $DB_NAME and user $DB_USER..."
  mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASSWORD -e  "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;" >> /dev/null 2>&1
  mysql -h $MYSQL_HOST -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL ON \`$DB_NAME\`.* TO \`$DB_USER\`@\`%\` IDENTIFIED BY '$DB_PASSWORD';" >> /dev/null 2>&1

}
