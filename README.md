# docker_scripts
My docker scripts

# CentOS 8

If firewall running, please:

```sh
firewall-cmd --permanent --zone=trusted --change-interface=docker0
firewall-cmd --permanent --zone=trusted --add-port=4243/tcp
firewall-cmd --reload
```

resolve error:

```
ERROR: http://dl-cdn.alpinelinux.org/alpine/v3.10/main: temporary error (try again later)
```