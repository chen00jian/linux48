---
title: zabbix的agent端安装配置
date: 2015-10-28
tags:
- zabbix
categories:
 - Monitor
---




## 下载zabbix

## 安装zabbix所需的组件

``yum -y install curl curl-devel net-snmp net-snmp-devel perl-DBI``

## 创建用户账号

```bash
groupadd zabbix
useradd -g zabbix zabbix
usermod -s /sbin/nologin zabbix
```


## 编译安装(agent)

```bash
tar zxvf zabbix-2.4.5.tar.gz 
cd zabbix-2.4.5
./configure --prefix=/usr/local/zabbix-agent --enable-agent  --enable-ipv6 --with-net-snmp --with-libcurl
make install
```

## 编辑agent端配置文件

```bash
[root@Server2 ~]# cat /usr/local/zabbix-agent/etc/zabbix_agentd.conf |grep -v "#"
LogFile=/tmp/zabbix_agentd.log
Server=10.10.3.225
ServerActive=10.10.3.225:10051
Hostname=10.128.0.81
```
## 启动守护进程agent

``/usr/local/zabbix-agent/sbin/zabbix_agentd ``

server启动端口为10051

iptables放行zabbix-agent的10051端口

``iptables -A INPUT -p tcp  --dport 10051 -j ACCEPT``

注：重启服务可直接kill掉zabbix进程再重新按照以上方法启动

或配置开机启动脚本

```bash
cd zabbix-2.4.5
cp misc/init.d/tru64/zabbix_agentd   /etc/init.d/zabbix_agentd
chmod 755 /etc/init.d/zabbix_agentd
vi /etc/init.d/zabbix_agentd
在文件头部的#!/bin/sh行下分别添加如下两行：
--------------
#chkconfig: 35 95 95
#description:zabbix agent
--------------
将DAEMON后面的参数改成你自定义的路径
DAEMON=/usr/local/zabbix-agent/sbin/zabbix_agentd
```

## 加入开机启动

```bash
chkconfig --add zabbix_agentd  
chkconfig zabbix_agentd on
```

## 重启服务：

``service zabbix_agentd restart``



