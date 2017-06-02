FROM ubuntu:xenial
MAINTAINER Pascal Martineau <pascal@lewebsimple.ca>

# Install package dependencies
RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" > /etc/apt/sources.list.d/ondrej-php-xenial.list \
  && echo "deb-src http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" >> /etc/apt/sources.list.d/ondrej-php-xenial.list \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C \
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  apache2 \
  ca-certificates \
  curl \
  git \
  less \
  imagemagick \
  iputils-ping \
  nano \
  openssh-client \
  php5.6 \
  php5.6-cli \
  php5.6-curl \
  php5.6-gd \
  php5.6-intl \
  php5.6-mbstring \
  php5.6-mcrypt \
  php5.6-mysqli \
  php5.6-xml \
  php5.6-zip \
  php-pear \
  php-xdebug \
  rsync \
  ssmtp \
  && rm -rf /var/lib/apt/lists/*

# Default Apache2 UID
ENV APACHE_UID 1000

# Copy configuration files
COPY config/ /

# Configure Apache2
RUN set -ex \

  # Load Apache environment variables
	&& . /etc/apache2/envvars \

	# Configure server FQDN
	&& a2enconf fqdn \

  # Enable Apache modules
  && a2enmod expires headers rewrite \
  && apache2ctl graceful \

  # Disable Indexes in default vhost
  && sed -e '/Options Indexes FollowSymLinks/ s/^#*/#/' -i /etc/apache2/apache2.conf \

  # Remove SSL vhost configuration
  && rm /etc/apache2/sites-available/default-ssl.conf \

 	# Output error log to stderr
 	&& ln -sfT /dev/stderr "${APACHE_LOG_DIR}/error.log" \
 	&& ln -sfT /dev/stdout "${APACHE_LOG_DIR}/access.log" \

  # Create Xdebug directory
  && mkdir -p /tmp/xdebug \

  # Change UID/GID of www-data to match local user
  && usermod --non-unique --uid ${APACHE_UID} www-data \
  && groupmod --non-unique --gid ${APACHE_UID} www-data \

  # Adjust directory permissions
  && chown -R www-data:www-data /var/www /tmp/xdebug

VOLUME ["/var/www/html","/tmp/xdebug"]
WORKDIR /var/www/html

EXPOSE 80

CMD ["/docker-entrypoint.sh"]
