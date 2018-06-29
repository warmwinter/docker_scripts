# PHP
#
# VERSION   5.6.x

FROM centos:latest

LABEL Description="PHP v5.6.x Docker" Vendor="Microvan Studio" Version="1.0.0"

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum update -y && \
    yum install yum-utils -y && \
    yum-config-manager --enable remi-php56 -y && \
    rm /etc/localtime -y && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    yum install -y php php-cli php-common php-dbg php-devel php-fpm \
        php-gd php-imap php-mbstring php-mcrypt php-mysqlnd php-opcache php-pdo \
        php-pecl-apcu php-pecl-igbinary php-pecl-memcache php-pecl-memcached \
        php-pecl-mongo php-pecl-redis php-pecl-xdebug php-process php-recode php-snmp \
        php-soap php-xcache php-xml && \
    sed -ri '/;error_log = syslog/a\error_log = \/var\/log\/php-fpm\/php_errors.log' /etc/php.ini && \
    sed -ri 's/upload_max_filesize = 2M/upload_max_filesize = 8M/g' /etc/php.ini && \
    sed -ri 's#;date.timezone =#date.timezone = ASIA/SHANGHAI#g' /etc/php.ini && \
    sed -ri 's#;emergency_restart_threshold = 0#emergency_restart_threshold = 50#g' /etc/php-fpm.conf && \
    sed -ri 's#;emergency_restart_interval = 0#emergency_restart_interval = 1m#g' /etc/php-fpm.conf && \
    sed -ri 's#listen = 127\.0\.0\.1:9000#listen = :::9000#g' /etc/php-fpm.d/www.conf && \
    sed -ri 's#listen\.allowed_clients = 127\.0\.0\.1#listen\.allowed_clients = 127\.0\.0\.1,172\.17\.0\.1#g' /etc/php-fpm.d/www.conf && \
    sed -ri 's#;request_slowlog_timeout = 0#request_slowlog_timeout = 2s#g' /etc/php-fpm.d/www.conf && \
    systemctl enable php-fpm && \
    systemctl start php-fpm

EXPOSE 9000

ENTRYPOINT ["/usr/sbin/init"]

    

