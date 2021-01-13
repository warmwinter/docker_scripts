#!/bin/sh

# Check if user is root
if [ $(id -u) -ne "0" ]; then
    printf "Error: You must be root to run this script!\n"
    exit 1
fi

# https://hub.docker.com/_/postgres
# Define variables
CMD='/usr/bin/docker'
IMAGEREPO='postgres'
IMAGETAG='13-alpine'
LISTEN_PORT=3309

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

# docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres
# docker run -it --rm --network some-network postgres psql -h some-postgres -U postgres

# rebuild the container

$CMD run --detach --interactive --name $IMAGEREPO-$IMAGETAG -e POSTGRES_PASSWORD='dbRoot6yhn&UJM' --privileged --publish 127.0.0.1:${LISTEN_PORT}:8088 --restart unless-stopped --tty $IMAGEREPO:$IMAGETAG  

# --volume /web/wwwroot:/web/wwwroot:rw --volume /web/docker/logs/${IMAGEREPO}:/var/log/php-fpm:rw

# check the running result

if [ $? -ne 0 ]; then
    echo "Build container fail, please check ..."
    exit 1
fi

printf "Build success ... \n"
exit 0
