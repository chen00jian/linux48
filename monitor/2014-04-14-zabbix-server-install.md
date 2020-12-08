---
title: zabbix的server端安装配置
date: 2014-04-14
tags:
- zabbix
categories:
 - Monitor
---

:::tip 
之前玩过cacti和nagios，算是一个大家耳熟能详的业内常用的的网管互补组合，但个人感觉前者由于调用snmp协议，导致有时候在网络不太稳定时会有数据丢失情况，后者nagios虽然不依赖于SNMP，但客户端的复杂的安装，初始配置以及需要读懂插件语法导致会让很多初学者望而却步。  
zabbix不仅吸取了两者的制图和动态监测的优点，而且很多插件以及常用脚本模板都是系统自带，最重要的配置相对于前两者简洁了很多，所以省去了很多学习成本，加之该监控系统是利用PHP语言写的，系统个人定制就无需使用者修改底层代码，而可以直接在WEB界面去按照自己的偏好设置，支持字体修改以及简体中文。<!-- more -->
:::

<!-- more -->


1.[下载zabbix][1]

2.安装zabbix所需的组件

```bash
yum -y install curl curl-devel net-snmp net-snmp-devel perl-DBI
`

3.创建用户账号

```bash
groupadd zabbix
useradd -g zabbix zabbix
usermod -s /sbin/nologin zabbix
```

4.创建zabbix数据库并导入zabbix数据库数据

```bash
mysql -u root -p123456
grant all on zabbix.* to zabbix@localhost identified by '123456';
create database zabbix;
exit;
tar zxvf zabbix-2.2.3.tar.gz
cd zabbix-2.2.3
mysql -uzabbix -p123456 zabbix < database/mysql/schema.sql
mysql -uzabbix -p123456 zabbix < database/mysql/images.sql
mysql -uzabbix -p123456 zabbix < database/mysql/data.sql
```

5.编译安装(server,agent)

```bash
./configure --prefix=/usr/local/zabbix-server --enable-server --enable-agent --with-mysql=/usr/local/mysql/bin/mysql_config --enable-ipv6 --with-net-snmp --with-libcurl
#./configure --prefix=/usr/local/zabbix-server-5.0.3 --enable-server --enable-agent --with-net-snmp --with-libcurl --enable-proxy --with-gettext   --enable-ipv6  --with-net-snmp   --enable-java  --with-libcurl  --with-mysql=/usr/local/mysql/bin/mysql_config   --with-libxml2
make install
```


6.编辑server端配置文件

```bash
vi /usr/local/zabbix-server/etc/zabbix_server.conf

修改以下参数

LogFile=/tmp/zabbix_server.log
DBHost=localhost
DBPort=3306
DBName=zabbix 
DBUser=zabbix 
DBPassword=123456
```

7、启动守护进程server

在服务器端运行启动zabbix_server

```/usr/local/zabbix-server/sbin/zabbix_server```

server启动端口为10051

iptables放行zabbix-server的10051端口

```iptables -A INPUT -p tcp  --dport 10051 -j ACCEPT```

注：重启服务可直接kill掉zabbix进程再重新按照以上方法启动

或配置开机启动脚本：

```bash
cd zabbix-2.2.2
cp misc/init.d/tru64/zabbix_server   /etc/init.d/zabbix_server
chmod 755 /etc/init.d/zabbix_server
vi /etc/init.d/zabbix_server
```

```vi /etc/init.d/zabbix_server```

在文件头部的#!/bin/sh行下分别添加如下两行：

```bash
--------------
#chkconfig: 35 95 95
#description:zabbix server
--------------
```

将DAEMON后面的参数改成你自定义的路径

```DAEMON=/usr/local/zabbix-server/sbin/zabbix_server```

加入开机启动

```bash
chkconfig --add zabbix_server  
chkconfig zabbix_server on
```

重启服务：

```bash
service zabbix_server restart
```

8.安装zabbix web界面  
复制ZABBIX PHP源代码文件  
zabbix的服务端程序是用php写的，因此需要一个支持php架构的服务器平台  
现在将ZABBIX安装目录下frontends/php下面的php源代码文件拷贝到web服务器html文件目录下面。

访问URL，安装过程中碰到的各种php扩展自行查找安装，直到调通全部OK！到此zabbix的server端配置完成。

 [1]: http://www.zabbix.com/download.php
