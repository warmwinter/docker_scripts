#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

# @see: https://github.com/docker-library/php
# @see: https://github.com/php/php-src

ARG ALPINE_VERSION=3.12
FROM alpine:${ALPINE_VERSION}

RUN echo ${ALPINE_VERSION}"\n"

ENV ALPINE_VERSION 3.12
ENV IGBINARY_VER 3.1.6
ENV REDIS_VER 5.3.2RC2
ENV XDEBUG_VER 3.0.0beta1
ENV SWOOLE_VER 4.5.5
ENV STOMP_VER 2.0.2

# dependencies required for running "phpize"
# these get automatically installed and removed by "docker-php-ext-*" (unless they're already installed)
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		re2c \
		bison

RUN set -eux \
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
    && echo '# Generated by NetworkManager' > /etc/resolv.conf \
    && echo 'nameserver 223.5.5.5' >> /etc/resolv.conf \
    && echo 'nameserver 223.6.6.6' >> /etc/resolv.conf \
#
# Config the System, inclue timezone
    && apk add --no-cache --virtual .system-deps tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && date \
    && apk del .system-deps

# persistent / runtime deps
RUN apk add --no-cache \
		ca-certificates \
		curl \
		tar \
		xz \
		libffi-dev \
		libpng-dev \
		imap-dev \
		icu-dev \
		libzip-dev \
# https://github.com/docker-library/php/issues/494
		openssl

# ensure www-data user exists
RUN set -eux; \
	addgroup -g 82 -S www-data; \
	adduser -u 82 -D -S -G www-data www-data
# 82 is the standard uid/gid for "www-data" in Alpine
# https://git.alpinelinux.org/aports/tree/main/apache2/apache2.pre-install?h=3.9-stable
# https://git.alpinelinux.org/aports/tree/main/lighttpd/lighttpd.pre-install?h=3.9-stable
# https://git.alpinelinux.org/aports/tree/main/nginx/nginx.pre-install?h=3.9-stable

ENV PHP_INI_DIR /usr/local/etc/php

# Some Enviroment
ENV php_conf_d ${PHP_INI_DIR}/conf.d/

RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
	[ ! -d /var/www/html ]; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; \
	chmod 777 /var/www/html

##<autogenerated>##
ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=apache --with-fpm-group=apache --disable-cgi
##</autogenerated>##

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# Adds GNU HASH segments to generated executables (this is used if present, and is much faster than sysv hash; in this configuration, sysv hash is also generated)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie"

ENV GPG_KEYS 42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312

ENV PHP_VERSION 8.0.0
ENV PHP_URL="https://github.com/php/php-src/archive/master.tar.gz" PHP_ASC_URL=""
ENV PHP_SHA256="" PHP_MD5=""

RUN set -eux; \
	\
	apk add --no-cache --virtual .fetch-deps gnupg; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	curl -fSL --progress-bar -o php.tar.gz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.gz" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_MD5" ]; then \
		echo "$PHP_MD5 *php.tar.gz" | md5sum -c -; \
	fi; \
	\
	if [ -n "$PHP_ASC_URL" ]; then \
		curl -fsSL -o php.tar.gz.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		done; \
		gpg --batch --verify php.tar.gz.asc php.tar.gz; \
		gpgconf --kill all; \
		rm -rf "$GNUPGHOME"; \
	fi; \
	\
	apk del --no-network .fetch-deps

COPY docker-php-source /usr/local/bin/

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		argon2-dev \
		coreutils \
		curl-dev \
		libedit-dev \
		libsodium-dev \
		libxml2-dev \
		linux-headers \
		oniguruma-dev \
		openssl-dev \
		sqlite-dev \
	; \
	\
	export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./buildconf; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors intead of just warnings
		--enable-option-checking=fatal \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
		--enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# https://wiki.php.net/rfc/argon2_password_hash (7.2+)
		--with-password-argon2 \
# https://wiki.php.net/rfc/libsodium
		--with-sodium=shared \
# always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
		--with-pdo-sqlite=/usr \
		--with-sqlite3=/usr \
		\
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		--enable-bcmath \
		--enable-exif \
		--with-ffi \
		--enable-gd \
		--enable-intl \
		--with-imap \
		--with-imap-ssl \
		--with-mysqli \
		--enable-sockets \
		--with-zip \
		\
# in PHP 7.4+, the pecl/pear installers are officially deprecated (requiring an explicit "--with-pear") and will be removed in PHP 8+; see also https://github.com/docker-library/php/issues/846#issuecomment-505638494
		--with-pear \
		\
# bundled pcre does not support JIT on s390x
# https://manpages.debian.org/stretch/libpcre3-dev/pcrejit.3.en.html#AVAILABILITY_OF_JIT_SUPPORT
		$(test "$gnuArch" != 's390x-linux-musl' && echo '--with-pcre-jit') \
		\
		${PHP_EXTRA_CONFIGURE_ARGS:-} \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; \
	make clean; \
	\
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
	cp -v php.ini-* "$PHP_INI_DIR/"; \
	\
	cd /; \
	docker-php-source delete; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache $runDeps; \
	\
# update pecl channel definitions https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
# smoke test
	php --version

COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/

# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
RUN docker-php-ext-enable sodium

# Install extension by complie
RUN set -eux; \
    mkdir -p /usr/src \
# 
# Fetch pecl
    && curl -fSL http://pecl.php.net/get/igbinary-$IGBINARY_VER.tgz -o igbinary.tgz \
    && curl -fSL http://pecl.php.net/get/redis-$REDIS_VER.tgz -o redis.tgz \
    && curl -fSL http://pecl.php.net/get/xdebug-$XDEBUG_VER.tgz -o xdebug.tgz \
    && curl -fSL http://pecl.php.net/get/swoole-$SWOOLE_VER.tgz -o swoole.tgz \
    && curl -fSL http://pecl.php.net/get/stomp-$STOMP_VER.tgz -o stomp.tgz \
# 
# Decompress
    && tar -zxvC /usr/src -f igbinary.tgz \
    && tar -zxvC /usr/src -f redis.tgz \
    && tar -zxvC /usr/src -f xdebug.tgz \
    && tar -zxvC /usr/src -f swoole.tgz \
    && tar -zxvC /usr/src -f stomp.tgz \
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
    && echo "xdebug.remote_enable = 1" >> ${php_conf_d}xdebug.ini \
    && echo "xdebug.remote_connect_back = 1" >> ${php_conf_d}xdebug.ini \
    && echo "xdebug.idekey = \"PHPSTORM\"" >> ${php_conf_d}xdebug.ini \
    && cd .. \
    && rm -rf /usr/src/xdebug-$XDEBUG_VER \
#
# Install swoole
    && cd /usr/src/swoole-$SWOOLE_VER \
    && phpize \
    && ./configure --enable-sockets --enable-async-redis --enable-openssl \
        --enable-http2 --enable-swoole --enable-mysqlnd \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && echo "extension=swoole.so" > ${php_conf_d}swoole.ini \
    && cd .. \
    && rm -rf /usr/src/swoole-$SWOOLE_VER \
#
# install stomp
#    && cd /usr/src/stomp-$STOMP_VER \
#    && phpize \
#    && ./configure --enable-stomp \
#    && make -j$(getconf _NPROCESSORS_ONLN) \
#    && make install \
#    && echo "extension=stomp.so" > ${php_conf_d}stomp.ini \
#
# APK Del
    && apk del --no-network .build-deps;

ENTRYPOINT ["docker-php-entrypoint"]
##<autogenerated>##
WORKDIR /var/www/html

RUN set -eux; \
	cd /usr/local/etc; \
	if [ -d php-fpm.d ]; then \
		# for some reason, upstream's php-fpm.conf.default has "include=NONE/etc/php-fpm.d/*.conf"
		sed 's!=NONE/!=!g' php-fpm.conf.default | tee php-fpm.conf > /dev/null; \
		cp php-fpm.d/www.conf.default php-fpm.d/www.conf; \
	else \
		# PHP 5.x doesn't use "include=" by default, so we'll create our own simple config that mimics PHP 7+ for consistency
		mkdir php-fpm.d; \
		cp php-fpm.conf.default php-fpm.d/www.conf; \
		{ \
			echo '[global]'; \
			echo 'include=etc/php-fpm.d/*.conf'; \
		} | tee php-fpm.conf; \
	fi; \
	{ \
		echo '[global]'; \
		echo 'error_log = /proc/self/fd/2'; \
		echo; echo '; https://github.com/docker-library/php/pull/725#issuecomment-443540114'; echo 'log_limit = 8192'; \
		echo; \
		echo '[www]'; \
		echo '; if we send this to /proc/self/fd/1, it never appears'; \
		echo 'access.log = /proc/self/fd/2'; \
		echo; \
		echo 'clear_env = no'; \
		echo; \
		echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
		echo 'catch_workers_output = yes'; \
		echo 'decorate_workers_output = no'; \
	} | tee php-fpm.d/docker.conf; \
	{ \
		echo '[global]'; \
		echo 'daemonize = no'; \
		echo; \
		echo '[www]'; \
		echo 'listen = 9000'; \
	} | tee php-fpm.d/zz-docker.conf

# Override stop signal to stop process gracefully
# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE 9000
CMD ["php-fpm"]
##</autogenerated>##
