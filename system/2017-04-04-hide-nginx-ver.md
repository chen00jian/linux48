---
title: 隐藏nginx服务器名称
date: 2017-04-04
tags:
- nginx
categories:
 - System
---


```bash


###  隐藏nginx服务器名称  重新编译ngxin   ###

[root@APServer3 nginx-1.4.4]# vim src/core/nginx.h 

/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#ifndef _NGINX_H_INCLUDED_
#define _NGINX_H_INCLUDED_


#define nginx_version      1004004
#define NGINX_VERSION      ""
#define NGINX_VER          "" NGINX_VERSION

#define NGINX_VAR          ""
#define NGX_OLDPID_EXT     ".oldbin"


#endif /* _NGINX_H_INCLUDED_ */




[root@APServer3 nginx-1.4.4]# ./configure --user=www --group=www --prefix=/usr/local/nginx --with-pcre=$setup_dir/nginx/pcre-8.30 --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-google_perftools_module

[root@APServer3 nginx-1.4.4]# make

[root@APServer3 nginx-1.4.4]# cp /usr/local/nginx/sbin/nginx  /usr/local/nginx/sbin/nginx.old 

[root@APServer3 nginx-1.4.4]# cp -rfp  objs/nginx /usr/local/nginx/sbin/
cp: overwrite `/usr/local/nginx/sbin/nginx'? y

[root@APServer3 nginx-1.4.4]# /etc/init.d/nginx restart

```

