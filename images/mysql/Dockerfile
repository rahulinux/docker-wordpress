FROM ubuntu:xenial
MAINTAINER Pascal Martineau <pascal@lewebsimple.ca>

FROM ubuntu:xenial
MAINTAINER Pascal Martineau <pascal@lewebsimple.ca>

# Copy Percona repository package
COPY percona-release_0.1-4.xenial_all.deb /tmp/

# Install package dependencies
RUN dpkg -i /tmp/percona-release_0.1-4.xenial_all.deb \
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates \
  cron \
  less \
  mysql-server \
  nano \
  percona-xtrabackup-24 \
  supervisor \
  && rm -rf /var/lib/apt/lists/* /tmp/percona-release_0.1-4.xenial_all.deb

# Default MySQL UID
ENV MYSQL_UID 1000

# Copy configuration files
COPY config/ /

# Configure MySQL and XtraBackup
RUN set -ex \

  # Create empty data and backup directories
  && rm -rf /var/lib/mysql \
  && mkdir -p /var/lib/mysql /var/run/mysqld /backup \

  # Change UID/GID of mysql to match local user
  && usermod --non-unique --uid ${MYSQL_UID} mysql \
  && groupmod --non-unique --gid ${MYSQL_UID} mysql \

  # Adjust directory ownership and permissions
  && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /backup \
  && chmod 777 /var/run/mysqld \

  # Adjust MySQL configuration (bind-address, log)
  && sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/mysql.conf.d/mysqld.cnf

VOLUME ["/var/lib/mysql","/backup"]

EXPOSE 3306

CMD ["/docker-entrypoint.sh"]
