# PHP Version 8.0.x

# https://hub.docker.com/_/php?tab=tags&page=1&name=fpm-alpine

FROM php:8.0-fpm-alpine3.16

LABEL Description="PHP v8.0.x Docker" Vendor="Demo Studio" Version="1.0.0"

# Some Enviroment
ENV php_conf_d /usr/local/etc/php/conf.d/

ENV ALPINE_VERSION 3.16
ENV IGBINARY_VER 3.2.7
ENV REDIS_VER 5.3.7
ENV XDEBUG_VER 3.1.5
ENV SWOOLE_VER 4.8.9

ARG LOCAL_MIRROR=""

RUN set -xe \
    && addgroup -g 48 -S apache \
    && adduser -u 48 -D -S -G apache apache \
# Add the user and group named apache, because the host is centos and mounted volume owner is apache(id 48)
#
# Change alpine mirror to demostic
    && mv /etc/apk/repositories /etc/apk/repositories.bak \
    && echo "https://mirrors.aliyun.com/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories \
    && echo "https://mirrors.aliyun.com/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories \
#
# Modify resolve.conf, use AliDNS (www.alidns.com)
    #&& echo '# Generated by NetworkManager' > /etc/resolv.conf \
    #&& echo 'nameserver 223.5.5.5' >> /etc/resolv.conf \
    #&& echo 'nameserver 223.6.6.6' >> /etc/resolv.conf \
#
# Config the System, inclue timezone
    && apk add --no-cache --virtual .system-deps tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && date \
    && apk del .system-deps \
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
#
# Add php.ini config
    && echo 'expose_php = Off' > ${php_conf_d}docker-vars.ini \
    && echo 'error_log = /var/log/php-fpm/php_errors.log' >> ${php_conf_d}docker-vars.ini \
    && echo 'variables_order = "GPCS"' >> ${php_conf_d}docker-vars.ini \
    && echo 'request_order = "GP"' >> ${php_conf_d}docker-vars.ini \
    && echo 'upload_max_filesize = 8M' >> ${php_conf_d}docker-vars.ini \
    && echo 'date.timezone = ASIA/SHANGHAI' >> ${php_conf_d}docker-vars.ini \
#
# add apk .phpext-deps, it's persistent
    && apk add --no-cache --virtual .php-extensions-deps \
        icu-dev \
# for intl extension
        libvpx-dev libjpeg-turbo-dev libpng-dev zlib-dev libxpm-dev freetype-dev \
        libwebp-dev \
# for gd extension
        nghttp2-dev hiredis-dev openssl-dev \
# for pgsql
        postgresql-dev \
# for swoole extension
#        libmcrypt-dev \
# for mcrype extension
#
# add apk build deps
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
#        wget \
#
# Create source dolder
    && mkdir -p /usr/src \
# Configure gd extension
    &&  docker-php-ext-configure gd --with-webp --with-jpeg \
        --with-xpm --with-freetype --enable-gd-jis-conv \
# Install exif gd intl mysqli pdo_mysql sockets
    && docker-php-ext-install bcmath exif gd intl mysqli pdo_mysql sockets pdo_pgsql pgsql
# 
# Install mysql
RUN if [ -z "$LOCAL_MIRROR" ]; then \
        curl --retry-delay 2 --retry 99 -fSL https://github.com/php/pecl-database-mysql/archive/refs/heads/master.tar.gz -o pecl-database-mysql-master.tar.gz; \
    else \
        curl --retry-delay 2 --retry 99 -fSL https://mirrors.inproc.top/pecl-database-mysql-master.tar.gz -o pecl-database-mysql-master.tar.gz; \
    fi
RUN tar -zxvC /usr/src -f pecl-database-mysql-master.tar.gz \
    && rm -f pecl-database-mysql-master.tar.gz \
    && cd /usr/src/pecl-database-mysql-master \
    && phpize \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && echo "extension=mysql.so" > ${php_conf_d}mysql.ini \
    && cd .. \
    && rm -rf /usr/src/pecl-database-mysql-master \
#
# Fetch pecl
    && curl --retry-delay 2 --retry 99 -fSL http://pecl.php.net/get/igbinary-$IGBINARY_VER.tgz -o igbinary.tgz \
    && curl --retry-delay 2 --retry 99 -fSL http://pecl.php.net/get/redis-$REDIS_VER.tgz -o redis.tgz \
    && curl --retry-delay 2 --retry 99 -fSL http://pecl.php.net/get/xdebug-$XDEBUG_VER.tgz -o xdebug.tgz \
    && curl --retry-delay 2 --retry 99 -fSL http://pecl.php.net/get/swoole-$SWOOLE_VER.tgz -o swoole.tgz \
# 
# Decompress
    && tar -zxvC /usr/src -f igbinary.tgz \
    && tar -zxvC /usr/src -f redis.tgz \
    && tar -zxvC /usr/src -f xdebug.tgz \
    && tar -zxvC /usr/src -f swoole.tgz \
#
# clean pecl compressed packages
    && rm -f igbinary.tgz redis.tgz xdebug.tgz \
    swoole.tgz \
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
    && echo "xdebug.mode=develop,debug" >> ${php_conf_d}xdebug.ini \
    && echo "xdebug.discover_client_host = true" >> ${php_conf_d}xdebug.ini \
    && echo "xdebug.idekey = \"PHPSTORM\"" >> ${php_conf_d}xdebug.ini \
    && cd .. \
    && rm -rf /usr/src/xdebug-$XDEBUG_VER \
#
# Install swoole
    && cd /usr/src/swoole-$SWOOLE_VER \
    && phpize \
    && ./configure --enable-sockets --enable-openssl \
        --enable-http2 --enable-swoole --enable-mysqlnd \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && echo "extension=swoole.so" > ${php_conf_d}swoole.ini \
    && cd .. \
    && rm -rf /usr/src/swoole-$SWOOLE_VER \
#
# clean apk build deps
    && apk del .build-deps

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE 9000

CMD ["php-fpm"]
