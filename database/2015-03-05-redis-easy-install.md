---
title: Redis安装及主从配置
date: 2015-03-05
tags:
- redis
categories:
 - Database
---




## Redis简介

:::tip 
redis是一个key-value存储系统。和Memcached类似，它支持存储的value类型相对更多，包括string(字符串)、list(链表)、set(集合)和zset(有序集合)。这些数据类型都支持push/pop、add/remove及取交集并集和差集及更丰富的操作，而且这些操作都是原子性的。在此基础上，redis支持各种不同方式的排序。与memcached一样，为了保证效率，数据都是缓存在内存中。区别的是redis会周期性的把更新的数据写入磁盘或者把修改操作写入追加的记录文件，并且在此基础上实现了master-slave(主从)同步。Redis 是一个高性能的key-value数据库。 redis的出现，很大程度补偿了memcached这类keyvalue存储的不足，在部分场合可以对关系数据库起到很好的补充作用。
:::


<!-- more -->

## 编译安装

```bash
yum -y install make gcc gcc-c++ tcl

wget http://download.redis.io/releases/redis-2.8.19.tar.gz

tar zxvf redis-2.8.19.tar.gz

cd redis-2.8.19

chmod 777 -R *

make PREFIX=/usr/local/redis-2.8.19  MALLOC=libc install

cp ./redis.conf /usr/local/redis-2.8.19/

mkdir -p  /data/redisdb

vim /usr/local/redis-2.8.19/redis.conf

nohup /usr/local/redis-2.8.19/bin/redis-server /usr/local/redis-2.8.19/redis.conf &

/usr/local/redis-2.8.19/bin/redis-cli

```

## 启动脚本

```bash
cat redis-2.8.19/start.sh
#!/bin/bash

dir=$(pwd)
nohup $dir/bin/redis-server redis.conf  >> redis.log &
```

## Redis主从配置

Redis的主从复制功能非常强大，一个master可以拥有多个slave，而一个slave又可以拥有多个slave，如此下去，形成了强大的多级服务器集群架构。

流程如下图

![][1]


安装过程如下；
此处为了演示，复制了一份副本，修改端口号和主从配置即可

```bash
cp -R redis-2.8.19   redis-2.8.19-slave

cat redis-2.8.19-slave/redis.conf  |grep port
port 6380

cat redis.conf  |grep slaveof 
slaveof 127.0.0.1 6379   # (映射到主服务器上)
```

如果master设置了验证密码，还需配置masterauth。

配置完之后启动slave的Redis服务，主从配置完成。

## 主从测试

在master和slave分别执行info命令，查看结果如下(这里只贴主从相关打印)：

**master**

```bash
# redis-2.8.19/redis-cli 
127.0.0.1:6379> info

# Replication
role:master
connected_slaves:1
slave0:ip=127.0.0.1,port=6380,state=online,offset=2063394,lag=0
master_repl_offset:2063394
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1014819
repl_backlog_histlen:1048576
```

**slave**

```bash
# redis-2.8.19-slave/redis-cli -p 6380
127.0.0.1:6380> info

# Replication
role:slave
master_host:127.0.0.1
master_port:6379
master_link_status:up
master_last_io_seconds_ago:2
master_sync_in_progress:0
slave_repl_offset:2080164
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```


然后在master执行 ``set name linux48``

在slave执行``get name``，看是否能得到linux48，如果能够得到值则说明配置成功。

```bash
# redis-2.8.19/redis-cli
127.0.0.1:6379> set name linux48
OK
127.0.0.1:6379> get name
"linux48"

# redis-2.8.19-slave/redis-cli -p 6380
127.0.0.1:6380> get name
"linux48"
```

[1]: ../images/hmAHbDZosczFB2u.jpg
