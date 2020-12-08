---
title: 多版本php共存搭建
date: 2014-01-30
tags:
- php
categories:
 - System
---



:::tip 
LNMP的环境，当前PHP版本5.3.28，遇到一个应用需求只支持PHP 5.5.21，又希望保持现有应用还是用PHP 5.3.28。也就是说需要两个版本的PHP同时存在，供nginx根据需要调用不同版本。
:::

<!-- more -->

#应用环境

LNMP的环境，当前PHP版本5.3.28，遇到一个应用需求只支持PHP 5.5.21，又希望保持现有应用还是用PHP 5.3.28。也就是说需要两个版本的PHP同时存在，供nginx根据需要调用不同版本。

#思路

Nginx是通过PHP-FastCGI与PHP交互的。而PHP-FastCGI运行后会通过文件、或本地端口两种方式进行监听，<!-- more -->在Nginx中配置相应的FastCGI监听端口或文件即实现Nginx请求对PHP的解释。

既然PHP-FastCGI是监听端口和文件的，那就可以让不同版本的PHP-FastCGI同时运行，监听不同的端口或文件，Nginx中根据需求配置调用不同的PHP-FastCGI端口或文件，即可实现不同版本PHP共存了。

#配置记录

下面记录简单的配置流程，基于已经安装了lnmp的centos环境。当前版本的PHP是5.3.28，位于/app/local/php5.3.28,下面安装php5.5.21


```bash
./configure  --with-openssl --prefix=/app/local/php5.5.21 --with-config-file-path=/app/local/php5.5.21/etc --with-jpeg-dir --with-png-dir --with-zlib --enable-xml --disable-rpath --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-mhash --enable-pcntl --enable-ftp --enable-zip --with-pdo-mysql=mysqlnd --enable-fpm --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-freetype-dir

make

make install
```



设置php的监听socket或者端口

```bash
[root@localhost local]# cat /app/local/php5.5.21/etc/php-fpm.conf |grep -v ";"       

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log

[www]
user = www
group = www

listen = run/php.scoket      
;注意若果是监听端口则是 listen = 127.0.0.1:9001

listen.owner = www
listen.group = www
 
pm = static
pm.max_children = 250
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
pm.status_path = /php-fpm_status
```


其他参数根据服务器环境和需求自行定制。

启动php-fpm

    /app/local/php5.5.21/sbin/php-fpm


#nginx配置

```bash
server {
        listen 80;
        server_name test.com;


        index index.php index.html index.htm;
        root  /www/test;


        error_page   404     /404.html;


        location ~ \.php$ {
            root           /www/test;
            fastcgi_pass   unix:/app/local/php5.5.21/run/php.scoket;
            #fastcgi_pass 127.0.0.1:9001; 
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  fastcgi_script_name;
            include        fastcgi.conf;
        }

}
```

今天安装好后nginx打开502，google了一下这位大神的文章[php5.5.12产生502错误解决方法](http://xuanwobbs.com.cn/archives/2014-05/php5-5-12-502.html)解决了


> *  如果有更多个php版本安装也是如此，此方法也可以适用于平滑升级php版本

> * 一个版本的php也可以指定相关配置文件来启动多个php的master,启动命令如下

    /app/local/php5.3.28/sbin/php-fpm -c /app/local/php5.3.28/etc/php2.ini -y /app/local/php5.3.28/etc/php-fpm2.conf 

show一下

    [root@localhost local]# ps -ef |grep php5
    root     16756     1  0 Jan29 ?        00:00:08 php-fpm: master process (/app/local/php5.3.28/etc/php-fpm2.conf)                                                
    root     16782     1  0 Jan29 ?        00:00:15 php-fpm: master process (/app/local/php5.3.28/etc/php-fpm.conf)
    root     23499     1  0 Jan30 ?        00:00:09 php-fpm: master process (/app/local/php5.5.21/etc/php-fpm.conf)
    root     44108 42716  0 16:36 pts/0    00:00:00 grep php5
    [root@localhost local]# 