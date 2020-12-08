---
title: zabbix的proxy端安装配置
date: 2015-10-29
tags:
- zabbix
categories:
 - Monitor
---

:::tip 
zabbix proxy可以代替zabbix server检索客户端的数据，然后把数据汇报给zabbix server，并且在一定程度上分担了zabbix server的压力。zabbix proxy可以非常简便的实现了集中式、分布式监控。
:::

<!-- more -->


## zabbix proxy 介绍


zabbix proxy使用场景:
>* 监控远程区域设备
>* 监控本地网络不稳定区域
>* 当zabbix监控上千设备时，使用它来减轻server的压力
>* 简化zabbix的维护


<!-- more -->

简易top如下

![][1]


zabbix proxy仅仅需要一条tcp连接到zabbix server,所以防火墙上仅仅需要加上一条规则即可，zabbix proxy数据库必须和server分开，否则数据会被破坏，毕竟这两个数据库的表大部分都相同。总之记住，数据库分开即可。
proxy收集到数据之后，首先将数据缓存在本地，然后在一定得时间之后传递给zabbix server，这个时间由proxy配置文件中参数ProxyLocalBuffer and ProxyOfflineBuffer决定.
zabbix proxy是一个数据收集器，它不计算触发器、不处理事件、不发送报警。

## 安装搭建zabbix proxy

安装mysql此处省略

```bash
yum -y install curl curl-devel net-snmp net-snmp-devel perl-DBI
tar zxvf zabbix-2.4.5.tar.gz 
cd zabbix-2.4.5
./configure --prefix=/usr/local/zabbix_proxy --enable-proxy --enable-agent --with-mysql=/usr/local/mysql/bin/mysql_config --with-net-snmp --with-libcurl
make install
```

## 建立数据库并授权

```sql
create database zabbix character set utf8;
grant all on zabbix.* to zabbix@localhost identified by 'zabbix';
flush privileges;
```

导入数据结构：

``mysql -uzabbix -p'zabbix' zabbix < database/mysql/schema.sql``

需要注意的是proxy不需要导入data.sql 和 images.sql 这两份SQL，否则会有问题

## 配置zabbix proxy

```bash
[root@server]# cat /usr/local/zabbix_proxy/etc/zabbix_proxy.conf |grep -v "#"
ProxyMode=1
Server=10.10.3.222
Hostname=10.10.3.225
LogFile=/tmp/zabbix_proxy.log
DBHost=10.10.3.222
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix
DBSocket=/data/mysql/mysql.sock 
DBPort=3306
ConfigFrequency=60
```

>* proxyMode 是代理模式，一会在zabbix server的web里面配置会有选择，0是主动模式，1是被动模式,我使1被动模式
>* Server 是指定zabbix Server 的地址
>* Hostname 是指定proxy的名称，一会在zabbix server的web配置里填的名称要和这个一样
>* ConfigFrequency 这个是server和proxy两端配置同步的时间间隔，server和proxy要设定同一个值才好，默认是3600，我想配置同步快一点，改成60

## 启动zabbix proxy

启动守护进程agent

``/usr/local/zabbix_proxy/sbin/zabbix_proxy``

zabbix_proxy启动端口为10051

iptables放行zabbix_proxy的10051端口

``iptables -A INPUT -p tcp --dport 10051 -j ACCEPT``

注：重启服务可直接kill掉zabbix进程再重新按照以上方法启动

或配置开机启动脚本：

```bash
cd zabbix-2.4.5
cp misc/init.d/tru64/zabbix_proxy   /etc/init.d/zabbix_proxy
chmod 755 /etc/init.d/zabbix_proxy
vi /etc/init.d/zabbix_proxy
在文件头部的#!/bin/sh行下分别添加如下两行：
--------------
#chkconfig: 35 95 95
#description:zabbix_proxy
--------------
将DAEMON后面的参数改成你自定义的路径
DAEMON=/usr/local/zabbix_proxy/sbin/zabbix_proxy
```

## 加入开机启动

```bash
chkconfig --add zabbix_proxy
chkconfig zabbix_proxy on
```

## 重启服务：

``service zabbix_proxy restart``

## 添加zabbix proxy节点

![][2]


## 添加被监控的主机

添加被监控的主机勾选**由系统代理程式监控**

![][3]


  [1]: http://r.loli.io/emamqy.png
  [2]: http://r.loli.io/Uf2qau.png
  [3]: http://r6.loli.io/iiENna.png
