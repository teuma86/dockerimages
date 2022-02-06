ARG PHP_TAG
FROM teuma86/php-fpm-m2:${PHP_TAG}

USER root

RUN install-php-extensions xdebug xsl sockets

COPY etc/*.ini /etc/
COPY etc/xdebug-config /usr/local/etc/php/conf.d/xdebug-config

RUN cat /usr/local/etc/php/conf.d/xdebug-config >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && rm /usr/local/etc/php/conf.d/xdebug-config

USER www-data