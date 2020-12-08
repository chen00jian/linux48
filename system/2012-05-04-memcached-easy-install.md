---
title: memcached简易安装
date: 2012-05-04
tags:
- memcached
categories:
 - System
---



Memcached是什么?

Memcached 是一个高性能的分布式内存对象缓存系统，用于动态Web应用以减轻数据库负载。它通过在内存中缓存数据和对象来减少读取数据库的次数，从而提供动态、数据库驱动网站的速度。

简单来说就是把数据缓存在内存之中，用户读取直接从内存读取，减轻数据库压力！（ps：服务器内存要有足够大）


闲话不多说，下面开始安装

用 getconf LONG_BIT 来查看机子多少位

下载libevent、memcached

    wget http://www.danga.com/memcached/dist/memcached-1.2.6.tar.gz
    wget http://www.monkey.org/~provos/libevent-1.2.tar.gz

解包

    cd /usr/local
    mkdir libevent
    mkdir memcached
    tar -xzvf libevent-1.2.tar.gz
    tar -xzvf memcached-1.2.6.tar.gz

处理libevent

    cd /usr/local/libevent-1.2/
    ./configure &#8211;prefix=/usr/local/libevent
    make;make install

处理memcached

    cd /usr/local/memcached-1.2.6/
    ./configure &#8211;prefix=/usr/local/memcached &#8211;with-libevent=/usr/local/libevent
    make ;make install
    ll /usr/local/libevent/lib/

存在类似如下文件

    libevent-1.2.so.1 -> libevent-1.2.so.1.0.3
    libevent-1.2.so.1.0.3
    libevent.a
    libevent.la
    libevent.so -> libevent-1.2.so.1.0.3

32位机

    ln -s /usr/local/libevent/lib/libevent-1.2.so.1 /usr/lib

64位机

    ln -s /usr/local/libevent/lib/libevent-1.2.so.1 /usr/lib64

查看帮助

    cd /usr/local/memcached

    /usr/local/memcached/bin/memcached -h

```bash
memcached 1.2.6

-p <num> TCP port number to listen on (default: 11211)

-U <num> UDP port number to listen on (default: 0, off)

-s <file> unix socket path to listen on (disables network support)

-a <mask> access mask for unix socket, in octal (default 0700)

-l <ip\_addr> interface to listen on, default is INDRR\_ANY

-d run as a daemon

-r maximize core file limit

-u <username> assume identity of <username> (only when run as root)

-m <num> max memory to use for items in megabytes, default is 64 MB

-M return error on memory exhausted (rather than removing items)

-c <num> max simultaneous connections, default is 1024

-k lock down all paged memory. Note that there is a

limit on how much memory you may lock. Trying to

allocate more than that would fail, so be sure you

set the limit correctly for the user you started

the daemon with (not for -u <username> user;

under sh this is done with &#8216;ulimit -S -l NUM_KB&#8217;).

-v verbose (print errors/warnings while in event loop)

-vv very verbose (also print client commands/reponses)

-h print this help and exit

-i print memcached and libevent license

-b run a managed instanced (mnemonic: buckets)

-P <file> save PID in <file>, only used with -d option

-f <factor> chunk size growth factor, default 1.25

-n <bytes> minimum space allocated for key+value+flags, default 48
```

出现如上信息是，表明安装正常

启动memcache：

    /usr/local/memcached/bin/memcached -d -m 512 -u root -l 192.168.1.1 -p 11211 -c 1000 -P /tmp/memcached.pid

启动参数说明：

-d 选项是启动一个守护进程，

-m 是分配给Memcache使用的内存数量，单位是MB，默认64MB

-u 是运行Memcache的用户，如果当前为root 的话，需要使用此参数指定用户

-l   是监听的服务器IP地址，默认为所有网卡

-p 是设置Memcache的TCP监听的端口，最好是1024以上的端口

-c 选项是最大运行的并发连接数，默认是1024

-P 是设置保存Memcache的pid文件

当然也有很多可选参数通过./memcached -help来查看帮助

也可以启动多个守护进程，但是端口不能重复

8.停止Memcache进程：

    ps aux |grep memcache

#kill掉进程

测试：

    telnet 192.168.1.3 11211

连接不上修改防火墙