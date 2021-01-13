#!/bin/sh

# Check if user is root
if [ $(id -u) -ne "0" ]; then
    printf "Error: You must be root to run this script!\n"
    exit 1
fi

# https://hub.docker.com/_/mariadb
# Define variables
CMD='/usr/bin/docker'
IMAGEREPO='mariadb'
IMAGETAG='10.5'
LISTEN_PORT=3308

# enter the path that exist the shell script.
MYFULLPATH=`/usr/bin/realpath $0`
MYDIRPATH=`/usr/bin/dirname $MYFULLPATH`

cd $MYDIRPATH

### First clean containers

# find the older contanier, and remove it
CONTAINERCNT=`$CMD ps --all --filter "ancestor=$IMAGEREPO:$IMAGETAG" | wc -l`

if [ $CONTAINERCNT -ge 2 ]; then
    echo "Find the older container(s), and removing it(s)"
    $CMD rm --force $($CMD ps --all --filter "ancestor=$IMAGEREPO:$IMAGETAG" --quiet)
    
    if [ $? -ne 0 ]; then
        echo "Remove container(s) fail, total $CONTAINERCNT (the number should be subtract one)"
        exit 1
    fi 
fi

# Using a custom MySQL configuration file
# docker run --name some-mariadb -v /my/custom:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mariadb:tag
# Configuration without a cnf file
# docker run --name some-mariadb -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mariadb:tag --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
# If you would like to see a complete list of available options, just run:
# docker run -it --rm mariadb:tag --verbose --help

# rebuild the container

$CMD run --detach --interactive --name $IMAGEREPO-$IMAGETAG -e MYSQL_ROOT_PASSWORD='dbRoot6yhn&UJM' -e MYSQL_USER='dbadmin' -e MYSQL_PASSWORD='dbAdmin7ujm*IK<' --privileged --publish 127.0.0.1:${LISTEN_PORT}:3306 --restart unless-stopped --tty $IMAGEREPO:$IMAGETAG --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

# --volume /web/wwwroot:/web/wwwroot:rw --volume /web/docker/logs/${IMAGEREPO}:/var/log/php-fpm:rw

# check the running result

if [ $? -ne 0 ]; then
    echo "Build container fail, please check ..."
    exit 1
fi

printf "Build success ... \n"
exit 0
