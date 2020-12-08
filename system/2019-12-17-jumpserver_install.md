---
title: 开源的堡垒机Jumpserver安装
date: 2019-12-17
tags:
- Jumpserver
- 堡垒机
categories:
 - System
---


官方文档
https://docs.jumpserver.org/zh/master/dockerinstall.html

-----

```bash
# install docker ....
# install mysql ....
# install redis ....
```

----

```bash
create database jumpserver default charset 'utf8';
grant all privileges on *.* to  jumpserver@'172.17.0.%' identified by 'passw0rd' ;
flush privileges;

if [ "$SECRET_KEY" = "" ]; then SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`; echo "SECRET_KEY=$SECRET_KEY" >> ~/.bashrc; echo $SECRET_KEY; else echo $SECRET_KEY; fi
if [ "$BOOTSTRAP_TOKEN" = "" ]; then BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`; echo "BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN" >> ~/.bashrc; echo $BOOTSTRAP_TOKEN; else echo $BOOTSTRAP_TOKEN; fi

mkdir -p /data/jumpserver

docker run --name jms_all -d \
    -v /data/jumpserver:/opt/jumpserver/data/media \
    -p 7000:80 \
    -p 2222:2222 \
    -e SECRET_KEY=JA6WDDZNxPO3ejlekhNfKyeSWudi0WHiGKiPMSdX9l2EbUxCJA \
    -e BOOTSTRAP_TOKEN=UUSvlvT6nKpkM8uk \
    -e DB_HOST=10.10.54.33 \
    -e DB_PORT=3306 \
    -e DB_USER=jumpserver \
    -e DB_PASSWORD='passw0rd' \
    -e DB_NAME=jumpserver \
    -e REDIS_HOST=10.10.54.33 \
    -e REDIS_PORT=6379 \
    -e REDIS_PASSWORD='passw0rd' \
    jumpserver/jms_all:latest

docker logs -f jms_all

#进入容器命令
docker exec -it jms_all /bin/bash


http://10.10.54.33:7000/
admin/admin
```


nginx反向代理

```bash
[root@ph102 vhost]# cat malai_jump.conf 
server {
        listen 443 ssl;
        server_name  jump.dmoin.com;

  ssl_certificate   /usr/local/nginx/conf/vhost/cert/dmoin.crt;
  ssl_certificate_key  /usr/local/nginx/conf/vhost/cert/dmoin.key;
  ssl_session_timeout 5m;
  ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;


        location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_buffering off;

        #支持WebSocket
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";


        proxy_pass http://10.10.54.33:7000;

        }
}



server
        {
                listen       80;
                server_name jump.dmoin.com;
                rewrite ^(.*) https://jump.dmoin.com$1 permanent;
        }
[root@ph102 vhost]# 
```

tcp 代理 注意加到nginx.conf主配http外部
```bash
stream {
upstream tcp_proxy{
hash $remote_addr consistent;
server 10.127.5.165:2222;
}

server {
listen 2222 so_keepalive=on;
proxy_connect_timeout 86400s;
proxy_timeout 86400s;
proxy_pass tcp_proxy;
}
}
```
