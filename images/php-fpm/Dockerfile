ARG PHP_TAG
FROM php:${PHP_TAG}

ENV COMPOSER_HOME=

ENV MAILHOG_HOST    mailhog
ENV MAILHOG_PORT    1025

# Refresh apt
RUN set -eux \
    && apt update -y \
    && apt upgrade -y

# Install PHP extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# List of PHP extensions
ARG PHP_EXTENSIONS="amqp bcmath gd gmp imagick intl msgpack opcache pdo_mysql redis soap sockets xmlrpc xsl zip"

# Install PHP extensions and other utilities
RUN chmod +x /usr/local/bin/install-php-extensions && sync \
	&& install-php-extensions ${PHP_EXTENSIONS} \
	&& apt update -y \
	&& apt install -y git npm gettext unzip pwgen nmap ncat jq

# Set primary INI file and PHP memory limit
RUN set -eux \
    && cp ${PHP_INI_DIR}/php.ini-development ${PHP_INI_DIR}/php.ini \
    && perl -pi -e 's/memory_limit(.*)/memory_limit=-1/g' ${PHP_INI_DIR}/php.ini

# Setup Composer 1 & 2
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp/composer
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer1
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer2

RUN set -eux; \
	cd /usr/local/etc/; \
	{ \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
	} | tee php-fpm.d/docker.conf; \
	{ \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = 9000'; \
	} | tee php-fpm.d/zz-docker.conf; \
    perl -pi -e 's/^(pid|error_log|daemonize)/;$1/g' php-fpm.conf; \
    perl -pi -e 's/^(listen)/;$1/g' php-fpm.d/www.conf; \
    perl -pi -e 's/^(php_admin_(value|flag))/;$1/g' php-fpm.d/www.conf


# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

## Warden
RUN apt update

RUN apt install -y pv sudo bind9-utils python3-pip bash-completion rsync socat oathtool \
        wget ack automake autoconf nano vim cron mariadb-server

RUN apt install -y python2 && ln -s /usr/bin/python2 /usr/bin/python

ENV NODE_VERSION    10
RUN npm install -g n \
    && n install ${NODE_VERSION} \
    && rm -rf /usr/local/n/versions/node

COPY docker-entrypoint /usr/local/bin/
COPY etc/profile.d/*.sh /etc/profile.d/
COPY etc/*.ini /etc/
COPY etc/opcache-config /usr/local/etc/php/conf.d/opcache-config
COPY etc/php.d/*.ini /usr/local/etc/php/conf.d
COPY etc/php.d/05-additions.ini.template /usr/local/etc/php/conf.d

RUN cat /usr/local/etc/php/conf.d/opcache-config >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
    && rm /usr/local/etc/php/conf.d/opcache-config

ARG TARGETARCH

# Install mhsendmail to support routing email through mailhog
RUN mkdir -p /tmp/mhsendmail \
    && cd /tmp/mhsendmail \
    && curl -vLOs https://github.com/drpayyne/mhsendmail/releases/download/v0.3.0/mhsendmail_linux_$TARGETARCH \
    && chmod +x mhsendmail_linux_$TARGETARCH \
    && mv mhsendmail_linux_$TARGETARCH /usr/local/bin/mhsendmail

# Install awscli to support data backfill workflows using S3 storage; segno for QR code generation
RUN pip3 install awscli segno --no-cache-dir

# Configure www-data user as primary php-fpm user for better local dev experience
RUN chmod 0755 ~www-data \
    && mkdir -p /var/www/html \
    && chown www-data:www-data /var/www/html \
    && echo "www-data ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd \
    && PHP_FPM_USER=$(grep -i '^user = ' /usr/local/etc/php-fpm.d/www.conf | awk '{print $3}') \
    && PHP_FPM_GROUP=$(grep -i '^group = ' /usr/local/etc/php-fpm.d/www.conf | awk '{print $3}') \
    && perl -pi -e 's/^(user|group) = php-fpm$/$1 = www-data/g' /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html
USER www-data

# Finish up
EXPOSE 9000
CMD ["php-fpm"]