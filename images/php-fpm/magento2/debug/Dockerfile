ARG PHP_TAG
FROM teuma86/warden-php-m2:${PHP_TAG}

USER root
RUN install-php-extensions xdebug-2.9.8 xsl sockets

# RUN set -eux \
#     && dnf install -y php-pecl-xdebug \
#     && dnf clean all \
#     && rm -rf /var/cache/dnf

COPY debug/etc/*.ini /etc/
COPY debug/etc/php.d/*.ini /usr/local/etc/php/conf.d/xdebug-config

USER www-data
