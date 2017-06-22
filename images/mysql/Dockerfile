FROM ubuntu:xenial
MAINTAINER Pascal Martineau <pascal@lewebsimple.ca>

FROM ubuntu:xenial
MAINTAINER Pascal Martineau <pascal@lewebsimple.ca>

# Install package dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  ca-certificates \
  less \
  mysql-server \
  nano \
  && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY config/ /

# Configure MySQL
RUN set -ex \
  && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
  && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
  && chmod 777 /var/run/mysqld \
  && sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/mysql.conf.d/mysqld.cnf

VOLUME ["/var/lib/mysql"]

EXPOSE 3306

CMD ["/docker-entrypoint.sh"]
