---
title: 关于PHP-FPM的backlog
date: 2015-06-08
tags:
- php
- php-fpm
categories:
 - System
---





php-fpm 必须注意**backlog**的设置，否则上压力就容易 无法连接、网关超时！
 
 
	;listen.backlog = -1

backlog数，-1表示无限制，由操作系统决定

由于fpm是多个进程是监听同一个套接字的，通过一个套接字锁来保证同一时刻只有一个进程可以accept，多进程间抢锁是需要消耗时间的

在backlog被设置成-1的情况下，如果fpm没有及时accept，那么在并发量很大的情况下势必会出现SYN超时重连了。

安装php-fpm时backlog一定要重新设置，不能用fpm默认配置的-1 ，可以根据机器的并发量来设置，建议设置在1024以上，最好是2的幂值（因为内核会调整成2的n次幂）。

有高并发的业务，就必须要调整backlog。对于PHP而言，需要注意的有3方面：

> * 1、操作系统 | sysctl
> * 2、WEB前端 | 比如：Nginx
> * 3、PHP后台 | 比如：php-fpm

操作系统以CentOS为例，可通过默认配置 /etc/sysctl.conf 文件进行调整。比如：

	net.core.somaxconn = 1048576 # 默认为128
	net.core.netdev_max_backlog = 1048576 # 默认为1000
	net.ipv4.tcp_max_syn_backlog = 1048576 # 默认为1024

WEB前端以Nginx为例，可通过默认配置 /etc/nginx/nginx.conf 文件中的监听选项来调整。比如：

	listen       80 backlog=8192; # 默认为511

PHP后台，以PHP-FPM为例，可以通过默认配置 /etc/php-fpm.d/www.conf 文件进行调整。比如：

	listen.backlog = 8192 # 默认为-1（由系统决定）

大系统下，如上3处都应该进行调整。

值得注意的是：

    PHP-FPM的配置文件中，关于listen.backlog选项的注释有些误导人：

	; Set listen(2) backlog. A value of '-1' means unlimited. 
	; Default Value: -1

实际上如果使用默认值，很容易出现后端无法连接的问题，按老文档上的解释这个默认是200。建议此处不要留空，务必设置一个合适的值。
