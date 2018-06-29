# PHP Version 5.6.x

FROM php:5-fpm-alpine

LABEL Description="PHP v5.6.x Docker" Vendor="Demo Studio" Version="1.0.0"

# Some Enviroment
ENV php_conf_d /usr/local/etc/php/conf.d/

ENV IGBINARY_VER 2.0.7
ENV REDIS_VER 4.0.2
ENV XDEBUG_VER 2.5.5
# xdebug newer version can not support php 5, only 7
# ENV SWOOLE_VER 1.10.5
# swoole newer version can not support php 5, only 7

RUN set -xe \
    && addgroup -g 48 -S apache \
    && adduser -u 48 -D -S -G apache apache \
# Add the user and group named apache, because the host is centos and mounted volume owner is apache(id 48)
# 
# Modify php-fpm configure files, change user/group, change logs position
    && sed -i \
        -e "s/^user\s*=\s*www-data/user = apache/g" \
        -e "s/^group\s*=\s*www-data/group = apache/g" \
        /usr/local/etc/php-fpm.d/www.conf \
#
# modify logs setting
    && sed -i \
        -e "s:^error_log\s*=\s*/proc/self/fd/2:error_log = /var/log/php-fpm/php-fpm.log:g" \
        -e '$a\; new log settings' \
        -e '$a\slowlog = /var/log/php-fpm/www_slow.log' \
        -e '$a\request_slowlog_timeout = 2s' \
        -e '$a\php_admin_value[error_log] = /var/log/php-fpm/www_error.log' \
        -e '$a\php_admin_flag[log_errors] = on' \
        /usr/local/etc/php-fpm.d/docker.conf \
# add apk .phpext-deps, it's persistent
    && apk add --no-cache --virtual .php-extensions-deps \
        icu-dev \
# for intl extension
        libvpx-dev libjpeg-turbo-dev libpng-dev zlib-dev libxpm-dev freetype-dev \
# for gd extension
#        nghttp2-dev hiredis-dev \
# for swoole extension
#
# add apk build deps
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
#        wget \
#
# Create source dolder
    && mkdir -p /usr/src \
# Install exif gd intl mysql mysqli pdo_mysql sockets
    && docker-php-ext-install exif gd intl mysql mysqli pdo_mysql sockets \
# 
# Fetch pecl
    && curl -fSL http://pecl.php.net/get/igbinary-$IGBINARY_VER.tgz -o igbinary.tgz \
    && curl -fSL http://pecl.php.net/get/redis-$REDIS_VER.tgz -o redis.tgz \
    && curl -fSL http://pecl.php.net/get/xdebug-$XDEBUG_VER.tgz -o xdebug.tgz \
#    && curl -fSL http://pecl.php.net/get/swoole-$SWOOLE_VER.tgz -o swoole.tgz \
# 
# Decompress
    && tar -zxvC /usr/src -f igbinary.tgz \
    && tar -zxvC /usr/src -f redis.tgz \
    && tar -zxvC /usr/src -f xdebug.tgz \
#    && tar -zxvC /usr/src -f swoole.tgz \
#
# clean pecl compressed packages
    && rm -f igbinary.tgz redis.tgz xdebug.tgz \
#    swoole.tgz \
#
# Install pecl igbinary
    && cd /usr/src/igbinary-$IGBINARY_VER \
    && phpize \
    && ./configure --enable-igbinary \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && echo "extension=igbinary.so" > ${php_conf_d}igbinary.ini \
    && cd .. \
    && rm -rf /usr/src/igbinary-$IGBINARY_VER \
#
# Install pecl phpredis
    && cd /usr/src/redis-$REDIS_VER \
    && phpize \
    && ./configure --enable-redis --enable-redis-igbinary \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && echo "extension=redis.so" > ${php_conf_d}redis.ini \
    && cd .. \
    && rm -rf /usr/src/redis-$REDIS_VER \
#
# Install xdebug
    && cd /usr/src/xdebug-$XDEBUG_VER \
    && phpize \
    && ./configure --enable-xdebug \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && echo "zend_extension=xdebug.so" > ${php_conf_d}xdebug.ini \
    && echo "xdebug.remote_enable = 1" >> ${php_conf_d}xdebug.ini \
    && echo "xdebug.remote_connect_back = 1" >> ${php_conf_d}xdebug.ini \
    && echo "xdebug.idekey = \"PHPSTORM\"" >> ${php_conf_d}xdebug.ini \
    && cd .. \
    && rm -rf /usr/src/xdebug-$XDEBUG_VER \
#
# Install swoole
#    && cd /usr/src/swoole-$SWOOLE_VER \
#    && phpize \
#    && ./configure --enable-sockets --enable-async-redis --enable-openssl \
#        --enable-http2 --enable-swoole --enable-mysqlnd \
#    && make -j$(getconf _NPROCESSORS_ONLN) \
#    && make install \
#    && echo "extension=swoole.so" > ${php_conf_d}swoole.ini \
#    && cd .. \
#    && rm -rf /usr/src/swoole-$SWOOLE_VER \
#
# clean apk build deps
    && apk del .build-deps

EXPOSE 9000

CMD ["php-fpm"]
