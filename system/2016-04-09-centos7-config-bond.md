---
title: centos7配置bond和bond跨网段改IP
date: 2016-04-09
tags:
- bond
categories:
 - System
---




##一. centos 7下查看网卡信息 
命令 ip addr 

最小化安装的Centos7系统并没有nano vim wget curl ifconfig lsof命令，这里首先安装一下

``yum -y install nano vim wget curl net-tools lsof``

安装后就可以使用ifconfig 等命令

配置bond

服务器有4个网卡分别为 ifcfg-em1 ifcfg-em2 ifcfg-em3 ifcfg-em4 网卡ifcfg-em1和ifcfg-em2配置bond0


翠花上配置

```
cd /etc/sysconfig/network-scripts
cp ifcfg-em1 ifcfg-bond0
```

网卡配置
```
vi /etc/sysconfig/network-scripts/ifcfg-em1

DEVICE=em1

NAME=em1

TYPE=Ethernet

BOOTPROTO=none

ONBOOT=yes

MASTER=bond4

SLAVE=yes
```
 
```
vi /etc/sysconfig/network-scripts/ifcfg-em2

DEVICE=em2

NAME=em2

TYPE=Ethernet

BOOTPROTO=none

ONBOOT=yes

MASTER=bond4

SLAVE=yes
```

```
vi /etc/sysconfig/network-scripts/ifcfg-bond0

DEVICE=bond0

NAME=bond0

TYPE=Ethernet

ONBOOT=yes

BOOTPROTO=none

BONDING_MASTER=yes  (centos7 下必须有这条命令，和centos6.5的区别)

IPADDR=*.*.*.*

GATEWAY=*.*.*.*

NETMASK=*.*.*.*

DNS1=*.*.*.*

DNS2=*.*.*.*

USERCTL=no

BONDING_OPTS="mode=1 miimon=100"
```

重启网卡（centos7下重启命令和centos6.5不同）

``systemctl  restart network``


bonding状态查看

`` cat /proc/net/bonding/bond0``


   
##二.关于网卡配置bond后需要更改IP到不同网段简单步骤
实验说明
服务器网卡em1、em2配置bond，IP地址为10.10.10.5
网卡em1和em2分别接在交换机SW1和SW2的五号端口在vlan10
因网络调整现在需要把交换机5号端口改到vlan20（114.80.218.*段） 
bond的IP地址改为114.80.218.5

配置思路
借助单网卡配置多IP的方法，增加一块虚拟网卡配置上需要更改的新网段IP114.80.218.6
重启网卡然后更改交换机配置 划分端口到新valn 20，变更完成后。就可以使用114.80.218.6远程服务器
然后在更改ifcfg-bond0的ip为114.80.218.5 随后删除ifcfg-bond0:0 变更完成。
配置ifcfg-bond0:0的这种情景，可以应用更改在服务器没有远程管理口，人又不在服务器旁边。
但是可以远程管理现有服务器和交换机。万一更改不成功还可以回退。通过原IP远程服务器。


翠花上配置
```
cd /etc/sysconfig/network-scripts

cp ifcfg-bond0 ifcfg-bond0:0

vi /etc/sysconfig/network-scripts/ifcfg-bond0:0

DEVICE=bond0:0

NAME=bond0:0

TYPE=Ethernet

ONBOOT=yes

BOOTPROTO=none

BONDING_MASTER=yes  (centos7 下必须有这条命令，和centos6.5的区别)

IPADDR=114.80.218.6

GATEWAY=114.80.218.1

NETMASK=255.255.255.0

DNS1=202.96.209.5

DNS2=202.96.209.133

USERCTL=no

BONDING_OPTS="mode=1 miimon=100"
```


重启网卡（centos7下重启命令和centos6.5不同）

``systemctl  restart network``

更改交换机配置把5号端口划分到vlan 20

ping 114.80.218.6可以到达

ssh 114.80.218.6 然后更改ifcfg-bond0的ip为114.80.218.5

```
vi /etc/sysconfig/network-scripts/ifcfg-bond0

DEVICE=bond0

NAME=bond0

TYPE=Ethernet

ONBOOT=yes

BOOTPROTO=none

BONDING_MASTER=yes  (centos7 下必须由这条命令，和centos6.5的区别)

IPADDR=114.80.218.5

GATEWAY=114.80.218.1

NETMASK=255.255.255.0

DNS1=202.96.209.5

DNS2=202.96.209.133

USERCTL=no

BONDING_OPTS="mode=1 miimon=100"
```

重启网卡（centos7下重启命令和centos6.5不同）

``systemctl  restart network``

ssh 114.80.218.5 删除ifcfg-bond0:0

``cd /etc/sysconfig/network-scripts``

``rm -rf ifcfg-bond0:0``

至此IP变更完成

关于测试
ping 114.80.218.5 

关闭交换机sw1的5号端口，没有掉包
开启交换机sw1的5号端口，等待端口起来

关闭交换机sw2的5号端口，没有掉包
开启交换机sw2的5号端口，等待端口起来
一切正常，收工