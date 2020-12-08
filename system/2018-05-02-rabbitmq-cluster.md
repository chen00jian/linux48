---
title: rabbitmq群集安装
date: 2018-05-02
tags:
- rabbitmq
categories:
 - System
---

# rabbit_mq 安装

```bash
yum install -y zlib zlib-devel make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel  ncurses-devel ncurses-devel xmlto zip unzip

####安装Python

wget https://www.python.org/ftp/python/2.7.5/Python-2.7.5.tgz
tar zxvf Python-2.7.5.tgz 
cd Python-2.7.5
vim Modules/Setup.dist 
#SSL=/usr/local/ssl
#_ssl _ssl.c \
#       -DUSE_SSL -I$(SSL)/include -I$(SSL)/include/openssl \
#       -L$(SSL)/lib -lssl -lcrypto
......
#zlib zlibmodule.c -I$(prefix)/include -L$(exec_prefix)/lib -lz
把注释去掉后开始执行安装
./configure --prefix=/usr/local/python27 --with-zlib=/usr/include
make && make install
cd /usr/bin/
mv python python26
cp /usr/local/python27/bin/python /usr/bin/
vi /usr/bin/yum
-----
#!/usr/bin/python26


####安装erlang

wget http://www.erlang.org/download/otp_src_R16B02.tar.gz
tar zxvf otp_src_R16B02.tar.gz 
cd otp_src_R16B02
./configure --prefix=/usr/local/erlang --with-ssl --enable-threads --enable-smp-support --enable-kernel-poll --enable-hipe
make 
make install
vim /etc/profile
ERL_HOME=/usr/local/erlang
export PATH=$PATH:$ERL_HOME/bin
source /etc/profile
erl


####安装rabbitmq

wget wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.5/rabbitmq-server-3.1.5.tar.gz
tar -xzvf rabbitmq-server-3.1.5.tar.gz 
cd rabbitmq-server-3.1.5
make
make install TARGET_DIR=/usr/local/rabbitmq SBIN_DIR=/usr/local/rabbitmq/sbin MAN_DIR=/usr/local/rabbitmq/man
cd /usr/local/rabbitmq/sbin/

#安装web插件管理界面
mkdir /etc/rabbitmq/
./rabbitmq-plugins enable rabbitmq_management

#启动
nohup ./rabbitmq-server start &
tail -f nohup.out 
ps aux | grep rabbitmq
netstat -tnlp | grep 5672
service iptables status
curl http://127.0.0.1:15672
username passwd : guest
```

```
一步启动Erlang node和Rabbit应用：./rabbitmq-server

在后台启动Rabbit node：./rabbitmq-server -detached

关闭整个节点（包括应用）：./rabbitmqctl stop 
```



# rabbit_mq 集群搭建

```

#需要创建集群的机器都需要统一加hosts

vim /etc/hosts
# rabbit_mq
10.127.0.11 zhenru_11
10.127.0.10 zhenru_10


#需要创建集群的机器cookie都要统一

vim /root/.erlang.cookie


#启动各个节点的MQ，如果已经是启动状态那么kill掉重启

ps -ef |grep erlang
kill 25958 25971

cd /usr/local/rabbitmq/sbin/
nohup ./rabbitmq-server start &



#加入集群

[root@zhenru_11 sbin]# ./rabbitmqctl stop_app
Stopping node rabbit@zhenru_11 ...
...done.
[root@zhenru_11 sbin]# ./rabbitmqctl join_cluster rabbit@zhenru_10
Clustering node rabbit@zhenru_11 with rabbit@zhenru_10 ...
...done (already_member).
[root@zhenru_11 sbin]# ./rabbitmqctl start_app
Starting node rabbit@zhenru_11 ...
...done.
[root@zhenru_11 sbin]# 

# 设置镜像队列策略
在任意一个节点上执行：
# rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'
将所有队列设置为镜像队列，即队列会被复制到各个节点，各个节点状态保持一直。

https://88250.b3log.org/rabbitmq-clustering-ha#

```



# 将rabbitmq集群中的某个节点移除

```

#首先将要移除的节点停机.
root@rabbitmq-03:~# rabbitmqctl stop
Stopping and halting node 'rabbit@rabbitmq-03' ...

#在主节点,也就是发起进群的主机上进行节点的移除.

root@rabbitmq-01:~# rabbitmqctl  -n rabbit@rabbitmq-01 forget_cluster_node rabbit@rabbitmq-03
Removing node 'rabbit@rabbitmq-03' from cluster ...
 
#然后查看集群状态信息.
 
root@rabbitmq-01:/var/lib/rabbitmq# rabbitmqctl cluster_status
Cluster status of node 'rabbit@rabbitmq-01' ...
[{nodes,[{disc,['rabbit@rabbitmq-01','rabbit@rabbitmq-02']}]},
{running_nodes,['rabbit@rabbitmq-02','rabbit@rabbitmq-01']},
{cluster_name,<<"rabbit@rabbitmq-01">>},
{partitions,[]}]
 
发现rabbitmq3节点已经被移除.
```

