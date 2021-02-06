#!/bin/sh

# Check if user is root
if [ $(id -u) -ne "0" ]; then
    printf "Error: You must be root to run this script!\n"
    exit 1
fi

# Define variables
CMD='/usr/bin/docker'
IMAGEREPO='discuz'
IMAGETAG='release'
LISTEN_HTTP=8080
LISTEN_HTTPS=8443

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

# Find the older image, and remove it
IMAGECNT=`$CMD image ls $IMAGEREPO:$IMAGETAG | wc -l`

if [ $IMAGECNT -ge 2 ]; then
    echo "Find the older image, and removing it"
    $CMD rmi -f $IMAGEREPO:$IMAGETAG
    
    if [ $? -ne 0 ]; then
        echo "Remove images(s) fail, total $IMAGECNT (the number should be subtract one)"
        exit 1
    fi
fi

# rebuild image

$CMD build --force-rm --pull --rm --tag $IMAGEREPO:$IMAGETAG . 

# check the buliding result

if [ $? -ne 0 ]; then
    echo "Build image fail, please check ..."
    exit 1
fi

echo "Build image success"

# rebuild the container

$CMD run --detach --interactive --name $IMAGEREPO-$IMAGETAG --privileged --publish 0.0.0.0:${LISTEN_HTTP}:80 --publish 0.0.0.0:${LISTEN_HTTPS}:443 --restart unless-stopped --tty --volume /web/wwwroot:/web/wwwroot:rw --volume /web/docker/logs/${IMAGEREPO}:/var/log/php-fpm:rw $IMAGEREPO:$IMAGETAG  

# check the running result

if [ $? -ne 0 ]; then
    echo "Build container fail, please check ..."
    exit 1
fi

printf "Build success ... \n"
exit 0
