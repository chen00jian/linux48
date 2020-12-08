---
title: awstats日志分析安装
date: 2015-03-13
tags:
- awstats
categories:
 - System
---




## fyi

Awstats是一个免费非常简洁而且强大有个性的网站日志分析工具。它可以统计您站点的如下信息：
一：访问量，访问次数，页面浏览量，点击数，数据流量等
二：精确到每月、每日、每小时的数据
三：访问者国家
四：访问者IP
五：Robots/Spiders的统计
六：访客持续时间
七：对不同Files type 的统计信息
八：Pages-URL的统计
九：访客操作系统浏览器等信息
十：其它信息（搜索关键字等等）


## install awstats

```bash
wget http://sourceforge.net/projects/awstats/files/AWStats/7.3/awstats-7.3.zip
unzip awstats-7.3.zip
cp -R awstats-7.3 /usr/local/awstats/
cd /usr/local/awstats/tools/
perl awstats_configure.pl
```

## Set webserver

```bash
cd awstats-7.3/wwwroot
cp -R * /home/wwwroot/awstats

vim /etc/awstats/awstats.hero.conf

server {
    listen       81;
    server_name  localhost;

        root   /home/wwwroot/awstats;
        index  index.html;

        location / {
allow 192.168.1.3;
deny all;

#auth_basic            "Restricted";
#auth_basic_user_file  /usr/local/senginx/conf/vhosts/hero.passwd;
        }
}
```


## GeoIP install

```bash
mkdir GeoIP
cd GeoIP

wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
wget http://geolite.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
gunzip GeoIP.dat.gz
gunzip GeoIPASNum.dat.gz
gunzip GeoLiteCity.dat.gz

wget http://geolite.maxmind.com/download/geoip/api/c/GeoIP-1.4.8.tar.gz
tar zxvf GeoIP-1.4.8.tar.gz
cd GeoIP-1.4.8/
libtoolize -f
./configure
make && make install
wget http://geolite.maxmind.com/download/geoip/api/perl/Geo-IP-1.39.tar.gz
tar zxvf Geo-IP-1.39.tar.gz
cd Geo-IP-1.39
perl Makefile.PL LIBS='-L/usr/local/lib'
make && make install

vim /etc/awstats/awstats.hero.conf

LoadPlugin="geoip GEOIP_STANDARD /opt/GeoIP/GeoIP.dat"
LoadPlugin="geoip_city_maxmind GEOIP_STANDARD /opt/GeoIP/GeoLiteCity.dat"
LoadPlugin="geoip_org_maxmind GEOIP_STANDARD /opt/GeoIP/GeoIPASNum.dat"

```


## Set the log format
```bash
vim /usr/local/senginx/conf/vhosts/default.conf 

log_format  awstats  '$remote_addr - $remote_user [$time_local] "$request" '
'$status $body_bytes_sent "$http_referer" '
'"$http_user_agent" "$http_x_forwarded_for"';


server {
    listen       80;
    server_name  localhost;

    location / {
        root   /data/source/;
        index  index.php;
    }

    location ~ \.php$ {
        root           /data/source/;
        #fastcgi_pass  127.0.0.1:9000;
        fastcgi_pass   unix:/usr/local/php/run/php.scoket;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  fastcgi_script_name;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 128k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
        include      fastcgi.conf;
        #include        fastcgi_params;
    }
        access_log logs/access.log awstats;
}

vim /etc/awstats/awstats.hero.conf 
LogFile="/app/local/senginx/logs/access_%YYYY-24%MM-24%DD-24.log"
```


## Set crontab

```bash
cat /opt/scripts/cut_nginx_logs.sh
#!/bin/bash
logs_path="/app/local/senginx/logs/"
mv ${logs_path}access.log ${logs_path}access_$(date -d "yesterday" +"%Y%m%d").log
/app/local/senginx/sbin/nginx -s reload

cat /opt/scripts/awstats.sh
#!/bin/bash
perl /usr/local/awstats/tools/awstats_buildstaticpages.pl -update -config=hero -lang=cn -dir=/app/data/site/awstats/ -awstatsprog=/usr/local/awstats/wwwroot/cgi-bin/awstats.pl

01 00 * * * sh /opt/scripts/cut_nginx_logs.sh
10 00 * * * sh /opt/scripts/awstats.sh
```
