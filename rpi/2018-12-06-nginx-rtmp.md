---
title: 树莓派使用nginx+rtmp搭建直播(监控)服务
date: 2018-12-06
tags:
- RaspberryPi
categories:
 - RaspberryPi
---




## 安装nginx和nginx-rtmp-module

前面安装依赖略...

```bash
wget http://nginx.org/download/nginx-1.9.4.tar.gz
git clone git://github.com/arut/nginx-rtmp-module.git 
cd nginx-1.9.4
./configure --user=www --group=www --prefix=/usr/local/nginx --with-pcre=/root/pcre-8.30     --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module     --with-google_perftools_module --add-module=/root/nginx-rtmp-module/
make
make install
mkdir -p /tmp/hls/
chmod 777 -R /tmp/hls/
```

## nginx配置文件

```bash
cat /usr/local/nginx/conf/nginx.conf
user  www www;

worker_processes 16;

error_log  /usr/local/nginx/logs/error.log  crit;

pid        /usr/local/nginx/logs/nginx.pid;

#Specifies the value for maximum file descriptors that can be opened by this process. 
worker_rlimit_nofile 65535;

events 
{
  use epoll;
  worker_connections 65535;
}

http 
{
  include       mime.types;
  default_type  application/octet-stream;

  #charset  gb2312;
      

limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

  server_names_hash_bucket_size 128;
  client_header_buffer_size 32k;
  large_client_header_buffers 4 32k;
  client_max_body_size 8m;
      
  sendfile on;
  tcp_nopush     on;

  keepalive_timeout 60;

  tcp_nodelay on;

  fastcgi_connect_timeout 300;
  fastcgi_send_timeout 300;
  fastcgi_read_timeout 300;
  fastcgi_buffer_size 128k;
  fastcgi_buffers 4 256k;
  fastcgi_busy_buffers_size 256k;
  fastcgi_temp_file_write_size 256k;

  gzip on;
  gzip_min_length  1k;
  gzip_buffers     4 16k;
  gzip_http_version 1.0;
  gzip_comp_level 2;
  gzip_types       text/plain application/x-javascript text/css application/xml;
  gzip_vary on;

  #limit_zone  crawler  $binary_remote_addr  10m;


server {
    listen       8081;
    server_name  localhost;

    #charset koi8-r;
    #access_log  logs/host.access.log  main;
    location / {
        root   /usr/local/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;
    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   html;
    }


location /hls {
        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }
        root /tmp;
        add_header Cache-Control no-cache;
}

            }

access_log off;

include vhost/*.conf;
    }


rtmp {

    server {
        listen 1935;  #监听的端口
        chunk_size 4000;

        application hls {  #rtmp推流请求路径
            live on;
            hls on;
            hls_path /tmp/hls/;
            hls_fragment 5s;
        }


    }
}
```
    

## 检查配置

```bash
/usr/local/nginx/sbin/nginx  -t
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
```

## H5页面编写

```html
cat /usr/local/nginx/html/index.html 
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <title></title>
    </head>
    <body>
        <video id="video" src="http://10.10.3.225:8081/hls/test.m3u8" controls="controls" autoplay     height="100%" width="100%">您的浏览器不支持。</video>
        <button type="button" style="text-align: center;"     onclick="launchFullScreen(document.getElementById('video'))">全屏</button>

    </body>

    <script type="text/javascript">
    //全屏幕播放
    function launchFullScreen(element) {
      if(element.requestFullScreen) {
        element.requestFullScreen();
      } else if(element.mozRequestFullScreen) {
        element.mozRequestFullScreen();
      } else if(element.webkitRequestFullScreen) {
        element.webkitRequestFullScreen();
      }
    }
    </script>
</html>
```

## 开始直播

打开OBS----fms URL填rtmp://10.10.3.225:1935/hls----播放路径填test----开始串流

## 访问

http://10.10.3.225:8081/hls/test.m3u8

http://10.10.3.225:8081

## 摄像头+斗鱼直播(监控)

----未完----


via

https://www.tuicool.com/articles/iauQNr

http://lib.csdn.net/article/liveplay/37304
