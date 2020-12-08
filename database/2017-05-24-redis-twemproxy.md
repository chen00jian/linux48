---
title: 基于Twemproxy的Redis集群方案
date: 2017-05-24
tags:
- redis
- twemproxy
categories:
 - Database
---


:::tip 
Twemproxy是一种代理分片机制，由Twitter开源。Twemproxy作为代理，可接受来自多个程序的访问，按照路由规则，转发给后台的各个Redis服务器，分片存储到多个redis实例中；再原路返回。
玩过nginx反向代理的就懂了。
:::

<!-- more -->




## 编译安装

```bash
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
wget https://codeload.github.com/twitter/twemproxy/zip/master

#查找旧版本autoconf，并且卸载
rpm -qf /usr/bin/autoconf
rpm -e --nodeps autoconf-2.63

#安装最新版本
tar zxvf autoconf-2.69.tar.gz 
cd autoconf-2.69 
./configure --prefix=/usr 
make && make install

#编译安装 twemproxy
unzip twemproxy-master.zip
cd twemproxy-master
autoreconf -fvi
./configure --prefix=/usr/local/twemproxy
make -j 8
make install

#设置环境变量：
echo "PATH=$PATH:/usr/local/twemproxy/sbin/" >> /etc/profile
source /etc/profile
```

## 创建相关目录

```bash
cd /usr/local/twemproxy
mkdir run conf
#存放配置文件和pid文件
```

## 配置文件

```bash
cat /usr/local/twemproxy/conf/nutcracker.yml
alpha:
  listen: 127.0.0.1:22121
  hash: fnv1a_64
  distribution: ketama
  auto_eject_hosts: true
  redis: true
  server_retry_timeout: 2000
  server_failure_limit: 1
  servers:
   - 127.0.0.1:7000:1
   - 127.0.0.1:7001:1
```

本地安装了2个redis实例并启动

## 启动Twemproxy服务

测试配置文件

```bash
nutcracker -t
nutcracker: configuration file 'conf/nutcracker.yml' syntax is ok
```

启动命令：

```bash
nutcracker -d -c /usr/local/twemproxy/conf/nutcracker.yml -p /usr/local/twemproxy/run/redisproxy.pid -o /usr/local/twemproxy/run/redisproxy.log
```

nutcracker用法与命令选项

**Options:**

>* -h, –help                        : 查看帮助文档，显示命令选项
>* -V, –version                     : 查看nutcracker版本
>* -t, –test-conf                   : 测试配置脚本的正确性
>* -d, –daemonize                   : 以守护进程运行
>* -D, –describe-stats              : 打印状态描述
>* -v, –verbosity=N                 : 设置日志级别 (default: 5, min: 0, max: 11)
>* -o, –output=S                    : 设置日志输出路径，默认为标准错误输出 (default: stderr)
>* -c, –conf-file=S                 : 指定配置文件路径 (default: conf/nutcracker.yml)
>* -s, –stats-port=N                : 设置状态监控端口，默认22222 (default: 22222)
>* -a, –stats-addr=S                : 设置状态监控IP，默认0.0.0.0 (default: 0.0.0.0)
>* -i, –stats-interval=N            : 设置状态聚合间隔 (default: 30000 msec)
>* -p, –pid-file=S                  : 指定进程pid文件路径，默认关闭 (default: off)
>* -m, –mbuf-size=N                 : 设置mbuf块大小，以bytes单位 (default: 16384 bytes)


## 测试

```bash
127.0.0.1:22121> set name linux48
OK
127.0.0.1:22121> set name2 linux482
OK


127.0.0.1:7000> KEYS *
1) "name"

127.0.0.1:7001> KEYS *
1) "name2"
```

发现我们的测试数据分片到了两个redis实例中。

## 生产环境

haproxy+keepalived+Redis-Sentinel+redis-master-slave
