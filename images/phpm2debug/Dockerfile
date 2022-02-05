ARG PHP_TAG
FROM teuma86/php-fpm-m2:${PHP_TAG}

USER root

RUN apt update

RUN apt-get install php7.4-xdebug -y

# RUN set -eux \
#     && apt-get install -y php-pecl-xdebug 
#     #&& apt- clean all \
#     #&& rm -rf /var/cache/dnf

COPY etc/*.ini /etc/
COPY etc/php.d/*.ini /etc/php.d/

USER www-data
