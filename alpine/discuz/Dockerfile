FROM alpine:3

LABEL Description="Discuz! X Docker" Vendor="Discuz! Team" Version="1.0.0"

# For man-pages
# apk add man man-pages
# NOTE: If you are using Alpine Linux 3.12 or above try
# apk add mandoc man-pages

# temporary deps
ENV TMP_DEPS \
	autoconf \
    cmake \
    curl-dev \
    diffutils \
	dpkg-dev dpkg \
	file \
	g++ \
	gcc \
	libc-dev \
    libtirpc-dev \
    linux-headers \
    libzip-dev \
	make \
    ncurses-dev \
    openssl-dev \
    patch \
	pkgconf \
	re2c \
    rpcgen \
    tzdata 

# persistent / runtime deps
ENV PST_DEPS \
	ca-certificates \
	curl \
	tar \
	xz \
# https://github.com/docker-library/php/issues/494
	openssl

# software versions
ENV MYSQL_VER 8.0.23

# System config
RUN set -xe \
# use aliyun mirror for repository
    mv /etc/apk/repositories /etc/apk/repositories.bak \
    && echo "https://mirrors.aliyun.com/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories \
    && echo "https://mirrors.aliyun.com/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories \
#
# Modify resolve.conf, use AliDNS (www.alidns.com)
    && echo '# Generated by NetworkManager' > /etc/resolv.conf \
    && echo 'nameserver 223.5.5.5' >> /etc/resolv.conf \
    && echo 'nameserver 223.6.6.6' >> /etc/resolv.conf
#

# Install APK packages
RUN apk add --no-cache $PST_DEPS
RUN apk add --no-cache --virtual .tmp-deps $TMP_DEPS

# patch header files
COPY unistd.patch /tmp/
RUN patch -u /usr/include/unistd.h < /tmp/unistd.patch \
    && rm -f /tmp/unistd.patch \

# continue system config
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && date \
# Create source folder
    && mkdir -p /usr/src \

# Download and extract software
    && curl -fSL -C - --retry 20 --retry-delay 3 https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-boost-${MYSQL_VER}.tar.gz -o mysql.tar.gz \
#
    && tar -zxvC /usr/src -f mysql.tar.gz \
#
    && rm -f mysql.tar.gz \

# Install MySQL
    && cd /usr/src/mysql-${MYSQL_VER} \
    && cd ../ \
    && rm -rf /usr/src/mysql-${MYSQL_VER} \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release -DMYSQL_DATADIR=/var/mysql/data \
        -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DDEFAULT_CHARSET=utf8mb4 \
        -DDEFAULT_COLLATION=utf8mb4_unicode_ci -DENABLE_DOWNLOADS=ON -DWITH_CURL=system \
        -DWITH_BOOST=/usr/src/mysql-${MYSQL_VER}/boost/boost_1_73_0/boost \
        -S /usr/src/mysql-${MYSQL_VER} -B /usr/src/mysql-${MYSQL_VER}-build \
    && cd /usr/src/mysql-${MYSQL_VER}-build \
    && make \
    && make install \
    && rm -rf /usr/src/mysql-${MYSQL_VER} \
        /usr/src/mysql-${MYSQL_VER}-build \

# Clear
    && apk del --no-network .tmp-deps