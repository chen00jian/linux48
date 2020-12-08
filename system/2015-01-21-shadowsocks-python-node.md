---
title: shadowsocks的python和nodejs版搭建
date: 2015-01-21
tags:
- shadowsocks
categories:
 - System
---




shadowsocks的nodejs版的不是很稳定，今天又搞了一台香港的机器，果断换成python试试，果然给力

## nodejs版搭建

nodejs环境搭建参见 https://gist.github.com/koy1619/3479170a3a763ffd8869

    git clone https://github.com/shadowsocks/shadowsocks-nodejs.git

    cd shadowsocks-nodejs

    vim config.json

    {
    "server":".0.0.0.0",
    "server_port":8388,
    "local_address":"0.0.0.0",
    "local_port":1080,
    "password":"barfoo!",
    "timeout":600,
    "method":"aes-256-cfb"
    }

启动服务

    nohup /opt/shadowsocks-nodejs/bin/ssserver &
    nohup /opt/shadowsocks-nodejs/bin/sslocal &

查看进程

    [root@test ~]# ps -ef |grep  node
    root     12969     1  0 Jan16 ?        00:02:07 node /opt/shadowsocks-nodejs/bin/ssserver
    root     12971     1  0 Jan16 ?        00:02:05 node /opt/shadowsocks-nodejs/bin/sslocal
    root     15118 15104  0 15:48 pts/0    00:00:00 grep node

nodejs版的不是很稳定，今天又搞了一台香港的机器，果断换成python试试，果然给力


## python版搭建

    yum -y install python-setuptools && easy_install pip
    yum -y install python-pip libevent python-devel git m2crypto
    pip install shadowsocks
    pip install gevent
    pip install M2Crypto
    pip install shadowsocks
    mkdir -p /etc/shadowsocks

    vim /etc/shadowsocks/config.json

    {
    "server":"0.0.0.0",
    "server_port":8388,
    "local_address":"0.0.0.0",
    "local_port":1080,
    "password":"barfoo!",
    "timeout":600,
    "method":"table"
    }


启动服务

    cd /etc/shadowsocks
    nohup ssserver &
    nohup sslocal &

查看进程

    [root@10-8-1-5 ~]# ps -ef |grep python  
    root     22599     1  0 12:36 ?        00:00:07 /usr/bin/python /usr/bin/ssserver
    root     22604     1  0 12:36 ?        00:00:07 /usr/bin/python /usr/bin/sslocal
    root     22797 22772  0 15:54 pts/1    00:00:00 grep python
    [root@10-8-1-5 ~]# 


需要注意防火墙开放**local_port**的端口号


Google Chrome浏览器安装SwitchyOmega插件导入下面的备份修改server地址即可使用。



* [备份点我][1]


[1]: http://pan.baidu.com/s/1pJ8zfv1 "备份点我"

