---
title: centos安装ossec
date: 2014-07-25
tags:
- ossec
categories:
 - System
---



## fyi

OSSEC是一款由Trend Micro（趋势科技）开发的开源的基于主机的入侵检测系统，可以简称为HIDS。它具备日志分析，文件完整性检查，策略监控，rootkit检测，实时报警以及联动响应等功能。它支持多种操作系统：Linux、Windows、MacOS、Solaris、HP-UX、AIX。属于企业安全之利器。

详细的介绍和文档可以参考官网网站：

http://www.ossec.net/

## 服务端安装

    计算机名：ossec-server.com
    IP地址：10.10.16.1

### server端支持环境安装



首先我们安装需要用到的关联库和软件，由于我们最终是需要把日志导入到MySQL中进行分析，以及需要通过web程序对报警结果进行展示，同时需要把本机当做SMTP，所以需要在本机安装MySQL、Apache和sendmail服务。在当前的终端中执行如下命令：

    [root@ossec-server ~]# yum install wget gcc make mysql mysql-server mysql-devel httpd php php-mysql sendmail
    启动httpd、mysql、sendmail服务
    [root@ossec-server ~]# /etc/init.d/httpd start
    [root@ossec-server ~]# /etc/init.d/mysqld start
    [root@ossec-server ~]# /etc/init.d/sendmail start

下面创建数据库以方便我们下面的安装配置，连接到本机的MySQL，然后执行如下命令：


    [root@ossec-server ~]# mysql -uroot -p
    mysql> create database ossec;
    mysql> grant INSERT,SELECT,UPDATE,CREATE,DELETE,EXECUTE on ossec.* to ossec@localhost;
    mysql> set password for ossec@localhost=PASSWORD('ossec');
    mysql> flush privileges;
    mysql> exit


### 安装OSSEC服务端程序

首先通过官网的链接下载当前的最新稳定版本 2.7 的服务端包，同时解压。

    [root@ossec-server ~]# wget http://www.ossec.net/files/ossec-hids-2.7.1.tar.gz
    [root@ossec-server ~]# tar zxf ossec-hids-2.7.1.tar.gz
    [root@ossec-server ~]# cd ossec-hids-2.7.1

为了使OSSEC支持MySQL，需要在安装前执行make setdb命令，如下

    [root@ossec-server ossec-hids-2.7.1]# cd src; make setdb; cd ..

看到如下的信息说明可以正常支持MySQL：

    Info: Compiled with MySQL support.

下面进入安装步骤，执行install.sh脚本，同时按照下面的信息进行填写：

```bash
[root@ossec-server ossec-hids-2.7.1]# sh install.sh 
which: no host in (/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/mysql/bin:/usr/local/jdk1.7.0_09//bin:/root/bin)

  ** Para instalação em português, escolha [br].
  ** 要使用中文进行安装, 请选择 [cn].
  ** Fur eine deutsche Installation wohlen Sie [de].
  ** Για εγκατάσταση στα Ελληνικά, επιλέξτε [el].
  ** For installation in English, choose [en].
  ** Para instalar en Español , eliga [es].
  ** Pour une installation en français, choisissez [fr]
  ** A Magyar nyelvű telepítéshez válassza [hu].
  ** Per l'installazione in Italiano, scegli [it].
  ** 日本語でインストールします．選択して下さい．[jp].
  ** Voor installatie in het Nederlands, kies [nl].
  ** Aby instalować w języku Polskim, wybierz [pl].
  ** Для инструкций по установке на русском ,введите [ru].
  ** Za instalaciju na srpskom, izaberi [sr].
  ** Türkçe kurulum için seçin [tr].
  (en/br/cn/de/el/es/fr/hu/it/jp/nl/pl/ru/sr/tr) [en]: cn
which: no host in (/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/mysql/bin:/usr/local/jdk1.7.0_09//bin:/root/bin)
 OSSEC HIDS v2.7.1 安装脚本 - http://www.ossec.net
 
 您将开始 OSSEC HIDS 的安装.
 请确认在您的机器上已经正确安装了 C 编译器.
 如果您有任何疑问或建议,请给 dcid@ossec.net (或 daniel.cid@gmail.com) 发邮件.
 
  - 系统类型: Linux ossec-server.com 2.6.32-431.el6.x86_64
  - 用户: root
  - 主机: ossec-server.com


  -- 按 ENTER 继续或 Ctrl-C 退出. --



1- 您希望哪一种安装 (server, agent, local or help)? server

  - 选择了 Server 类型的安装.

2- 正在初始化安装环境.

 - 请选择 OSSEC HIDS 的安装路径 [/usr/local/ossec]: /usr/local/ossec

    - OSSEC HIDS 将安装在  /usr/local/ossec .


3- 正在配置 OSSEC HIDS.

  3.1- 您希望收到e-mail告警吗? (y/n) [y]: y
   - 请输入您的 e-mail 地址? koy1619@linux.com
   - 请输入您的 SMTP 服务器IP或主机名 ? 127.0.0.1

  3.2- 您希望运行系统完整性检测模块吗? (y/n) [y]: y

   - 系统完整性检测模块将被部署.

  3.3- 您希望运行 rootkit检测吗? (y/n) [y]: y

   - rootkit检测将被部署.
       
  3.4- 关联响应允许您在分析已接收事件的基础上执行一个
       已定义的命令.
       例如,你可以阻止某个IP地址的访问或禁止某个用户的访问权限.
       更多的信息,您可以访问:
       http://www.ossec.net/en/manual.html#active-response
   - 您希望开启联动(active response)功能吗? (y/n) [y]: y


     - 关联响应已开启

   - 默认情况下, 我们开启了主机拒绝和防火墙拒绝两种响应.
     第一种情况将添加一个主机到 /etc/hosts.deny.
     第二种情况将在iptables(linux)或ipfilter(Solaris,
     FreeBSD 或 NetBSD）中拒绝该主机的访问.
   - 该功能可以用以阻止 SSHD 暴力攻击, 端口扫描和其他
     一些形式的攻击. 同样你也可以将他们添加到其他地方,
     例如将他们添加为 snort 的事件.

   - 您希望开启防火墙联动(firewall-drop)功能吗? (y/n) [y]: y

     - 防火墙联动(firewall-drop)当事件级别 >= 6 时被启动

   - 联动功能默认的白名单是:
      - 10.10.16.1

   - 您希望添加更多的IP到白名单吗? (y/n)? [n]: n

  3.5- 您希望接收远程机器syslog吗 (port 514 udp)? (y/n) [y]: y

   - 远程机器syslog将被接收.

  3.6- 设置配置文件以分析一下日志:
    -- /var/log/messages
    -- /var/log/secure
    -- /var/log/maillog

                            
 -如果你希望监控其他文件, 只需要在配置文件ossec.conf中
  添加新的一项. 
  任何关于配置的疑问您都可以在 http://www.ossec.net 找到答案.


  --- 按 ENTER 以继续 ---
```

最后敲回车即可安装到`/usr/local/ossec`,注意上面的`email`地址和`白名单`后面可以在配置文件中修改。

### OSSEC服务端配置
上面只是安装好了OSSEC服务端，下面则是为了配置服务端，使其工作正常。执行下面命令启用数据库支持：

    [root@ossec-server ossec-hids-2.7.1]# /usr/local/ossec/bin/ossec-control enable database

然后导入MySQL表结构到MySQL中：

    [root@ossec-server ossec-hids-2.7.1]# mysql -uossec -p ossec < src/os_dbd/mysql.schema

修改配置文件的权限，否则会启动服务失败：

    [root@ossec-server ossec-hids-2.7.1]# chmod u+w /usr/local/ossec/etc/ossec.conf

然后编辑ossec.conf文件，在ossec_config中添加MySQL配置：

```bash
  <database_output>
      <hostname>localhost</hostname>
      <username>ossec</username>
      <password>ossec</password>
      <database>ossec</database>
      <type>mysql</type>
  </database_output>
```

由于我们在前面的安装过程中支持接受远程机器的syslog，所以我们还需要对ossec.conf文件中的syslog部分进行配置，修改ossec.conf文件，按照下面的内容进行修改，把我们网段可以全添加进去：

```bash
  <remote>
    <connection>syslog</connection>
    <allowed-ips>10.10.16.0/24</allowed-ips>
  </remote>
```

然后添加我们需要监控的客户机的白名单IP地址

```bash
  <global>
    <white_list>127.0.0.1</white_list>
    <white_list>^localhost.localdomain$</white_list>
    <white_list>10.10.16.2</white_list>
    <white_list>10.10.16.3</white_list>
    <white_list>10.10.16.4</white_list>
    ...
  </global>
```

如果有多个邮件的收件人需要添加

```bash
  <global>
    <email_notification>yes</email_notification>
    <email_to>koy@linux.com</email_to>
    <email_to>koy2@linux.com</email_to>
    <email_to>koy3@linux.com</email_to>
    <smtp_server>127.0.0.1</smtp_server>
    <email_from>ossecm@ossec-server.com</email_from>
  </global>
```

在服务器上添加客户端，执行如下命令，按照提示进行输：

```bash
[root@ossec-server ossec-hids-2.7.1]# /usr/local/ossec/bin/manage_agents 


****************************************
* OSSEC HIDS v2.7.1 Agent manager.     *
* The following options are available: *
****************************************
   (A)dd an agent (A).
   (E)xtract key for an agent (E).
   (L)ist already added agents (L).
   (R)emove an agent (R).
   (Q)uit.
Choose your action: A,E,L,R or Q: A

- Adding a new agent (use '\q' to return to the main menu).
  Please provide the following:
   * A name for the new agent: client1
   * The IP Address of the new agent: 10.10.16.2
   * An ID for the new agent[001]: 001
Agent information:
   ID:001
   Name:client1
   IP Address:10.10.16.2

Confirm adding it?(y/n): y
Agent added.


****************************************
* OSSEC HIDS v2.7.1 Agent manager.     *
* The following options are available: *
****************************************
   (A)dd an agent (A).
   (E)xtract key for an agent (E).
   (L)ist already added agents (L).
   (R)emove an agent (R).
   (Q)uit.
Choose your action: A,E,L,R or Q: 
```

添加完客户端之后，还需要生成密钥，选择E选项

```bash
****************************************
* OSSEC HIDS v2.7.1 Agent manager.     *
* The following options are available: *
****************************************
   (A)dd an agent (A).
   (E)xtract key for an agent (E).
   (L)ist already added agents (L).
   (R)emove an agent (R).
   (Q)uit.
Choose your action: A,E,L,R or Q: e

Available agents: 
   ID: 001, Name: client1, IP: 10.10.16.2
Provide the ID of the agent to extract the key (or '\q' to quit): 001

Agent key information for '001' is: 
MDAyIGNsaWVudDEgMTAuMTAuMTYuMiA2MDQ3NTc4NDBmZWE4ZTkyZDcxYjk3ZGY4NmNmMzIyY2Y0OGIwNjRlMTE2NDM5Yzk2Y2JkMGEyMDllNTVmMGQ4

** Press ENTER to return to the main menu.
```

到现在就可以启动我们的ossec服务端了。

    [root@ossec-server ossec-hids-2.7.1]# /usr/local/ossec/bin/ossec-control start


查看监听端口

```bash
[root@ossec-server analogi-master]# netstat -antup|grep ossec
tcp        0      0 127.0.0.1:43425             127.0.0.1:3306              ESTABLISHED 1841/ossec-dbd      
udp        0      0 0.0.0.0:514                 0.0.0.0:*                               1865/ossec-remoted  
udp        0      0 0.0.0.0:1514                0.0.0.0:*                               1866/ossec-remoted  
[root@ossec-server analogi-master]# 
```

如果开启iptables，则需要开放这2个UDP端口到client

## 客户端安装


    计算机名：client1.com
    IP地址：10.10.16.2


客户端也需要安装gcc编译器


    [root@client1 ~]# yum -y install gcc

安装ossec客户端程序

```bash
[root@client1 ossec-hids-2.7.1]# sh install.sh 

  ** Para instalação em português, escolha [br].
  ** 要使用中文进行安装, 请选择 [cn].
  ** Fur eine deutsche Installation wohlen Sie [de].
  ** Για εγκατάσταση στα Ελληνικά, επιλέξτε [el].
  ** For installation in English, choose [en].
  ** Para instalar en Español , eliga [es].
  ** Pour une installation en français, choisissez [fr]
  ** A Magyar nyelvű telepítéshez válassza [hu].
  ** Per l'installazione in Italiano, scegli [it].
  ** 日本語でインストールします．選択して下さい．[jp].
  ** Voor installatie in het Nederlands, kies [nl].
  ** Aby instalować w języku Polskim, wybierz [pl].
  ** Для инструкций по установке на русском ,введите [ru].
  ** Za instalaciju na srpskom, izaberi [sr].
  ** Türkçe kurulum için seçin [tr].
  (en/br/cn/de/el/es/fr/hu/it/jp/nl/pl/ru/sr/tr) [en]: cn
 OSSEC HIDS v2.7.1 安装脚本 - http://www.ossec.net
 
 您将开始 OSSEC HIDS 的安装.
 请确认在您的机器上已经正确安装了 C 编译器.
 如果您有任何疑问或建议,请给 dcid@ossec.net (或 daniel.cid@gmail.com) 发邮件.
 
  - 系统类型: Linux client1.com 2.6.32-279.el6.x86_64
  - 用户: root
  - 主机: client1.com


  -- 按 ENTER 继续或 Ctrl-C 退出. --



1- 您希望哪一种安装 (server, agent, local or help)? agent

  - 选择了 Agent(client) 类型的安装.

2- 正在初始化安装环境.

 - 请选择 OSSEC HIDS 的安装路径 [/usr/local/ossec]: /usr/local/ossec

    - OSSEC HIDS 将安装在  /usr/local/ossec .

3- 正在配置 OSSEC HIDS.

  3.1- 请输入 OSSEC HIDS 服务器的IP地址或主机名: 10.10.16.1

   - 添加服务器IP  10.10.16.1

  3.2- 您希望运行系统完整性检测模块吗? (y/n) [y]: y

   - 系统完整性检测模块将被部署.

  3.3- 您希望运行 rootkit检测吗? (y/n) [y]: y

   - rootkit检测将被部署.

  3.4 - 您希望开启联动(active response)功能吗? (y/n) [y]: y


  3.5- 设置配置文件以分析一下日志:
    -- /var/log/messages
    -- /var/log/secure
    -- /var/log/maillog

                            
 -如果你希望监控其他文件, 只需要在配置文件ossec.conf中
  添加新的一项. 
  任何关于配置的疑问您都可以在 http://www.ossec.net 找到答案.


  --- 按 ENTER 以继续 ---
```

敲玩回车即可完成安装，然后需要添加一下密钥，把刚才在server端生成的密钥复制下来

```bash
[root@client1 ossec-hids-2.7.1]# /usr/local/ossec/bin/manage_agents


****************************************
* OSSEC HIDS v2.7.1 Agent manager.     *
* The following options are available: *
****************************************
   (I)mport key from the server (I).
   (Q)uit.
Choose your action: I or Q: i

* Provide the Key generated by the server.
* The best approach is to cut and paste it.
*** OBS: Do not include spaces or new lines.

Paste it here (or '\q' to quit): MDAyIGNsaWVudDEgMTAuMTAuMTYuMiA2MDQ3NTc4NDBmZWE4ZTkyZDcxYjk3ZGY4NmNmMzIyY2Y0OGIwNjRlMTE2NDM5Yzk2Y2JkMGEyMDllNTVmMGQ4

Agent information:
   ID:001
   Name:client1
   IP Address:10.10.16.2

Confirm adding it?(y/n): y
Added.
** Press ENTER to return to the main menu.



****************************************
* OSSEC HIDS v2.7.1 Agent manager.     *
* The following options are available: *
****************************************
   (I)mport key from the server (I).
   (Q)uit.
Choose your action: I or Q: 
```

这样即可完成client端安装，启动ossec服务

    [root@client1 ossec-hids-2.7.1]# /usr/local/ossec/bin/ossec-control start 


之后就可以收到服务器log更新的邮件了，但是这样子还不够，我们需要通过更加直观的方式统一集中式的查看服务器的log情况，这就需要安装web-gui

## WEB-GUI安装
ossec官方提供的ossec-wui    https://github.com/ossec/ossec-wui
github开源analogi-master   https://github.com/ECSC/analogi/archive/master.zip

### ossec官方ossec-wui 安装方法
下载解压之后放到apache的web目录，并加apache用户权限

    [root@ossec-server ossec-wui-master]# chown -R apache.apache /usr/local/httpd/htdocs/ossec-wui-master/

执行安装脚本

```bash
[root@ossec-server ossec-wui-master]# sh setup.sh 
Setting up ossec ui...

Username: root
New password: 
Re-type new password: 
Adding password for user root
Enter your web server user name (e.g. apache, www, nobody, www-data, ...)
apache
sed：-e 表达式 #1，字符 22：未终止的“s”命令
Enter your OSSEC install directory path (e.g. /var/ossec)
/usr/local/ossec
You must restart your web server after this setup is done.

Setup completed successfuly.
```

修改配置文件中的ossec_dir路径

```bash
[root@ossec-server ossec-wui-master]# vim /usr/local/httpd/htdocs/ossec-wui-master/ossec_conf.php 
<?php

/* OSSEC Configuration for the UI. Make sure to set
 * right ossec_dir in here. If your server does not
 * have much memory available, reduce the max_alerts
 * variable to something smaller.
 */

/* Ossec directory */
$ossec_dir="/usr/local/ossec";


/* Maximum alerts per page */
$ossec_max_alerts_per_page = 1000;


/* Default search values */
$ossec_search_level = 7;
$ossec_search_time = 14400;


/* Default refreshing time */
$ossec_refresh_time = 90;

?>
```

修改`php.ini`

     max_execution_time = 180
     max_input_time = 180
     memory_limit = 30M

重启web服务即可查看web界面

![][1]


### github开源analogi安装方法
下载并解压放到web目录，只需要修改一下mysql的连接池就ok

```bash
[root@ossec-server analogi-master]# mv db_ossec.php.new db_ossec.php
[root@ossec-server analogi-master]# vim db_ossec.php
<?php
/*
 * Copyright (c) 2012 Andy 'Rimmer' Shepherd <andrew.shepherd@ecsc.co.uk> (ECSC Ltd).
 * This program is free software; Distributed under the terms of the GNU GPL v3.
 */

define ('DB_USER_O', 'ossec');
define ('DB_PASSWORD_O', 'ossec');
define ('DB_HOST_O', 'localhost');
define ('DB_NAME_O', 'ossec');

$db_ossec = mysql_connect (DB_HOST_O, DB_USER_O, DB_PASSWORD_O) OR die ('Could not connect to SQL : ' . mysql_error() . "<br/>Click <a href='' onclick='document.cookie=\"ossecdbjs=;expires=Thu, 01 Jan 1970 00:00:00 GMT\"' >HERE</a> to s
elect your main OSSEC DB");

mysql_select_db (DB_NAME_O, $db_ossec) OR die ('Could not select the database : ' . mysql_error() . "<br/>Click <a href='' onclick='document.cookie=\"ossecdbjs=;expires=Thu, 01 Jan 1970 00:00:00 GMT\"' >HERE</a> to select your main OSSE
C DB");

?>
```

web预览
![请输入图片描述][2]


  [1]: ../images/iynbcPlEYCM6LvI.jpg
  [2]: ../images/pTiXC9eU2NwlqFz.jpg


## FAQ：
发现无数据或者是看不到客户端，请查看`iptables`是否开放`udp`的`514`和`1514`端口并查看是否监听

web查看显示的时间不正确，可修改`php.ini`的date.timezone = Asia/Shanghai即可

sendmail邮件发不出，可修改查看主机名是否规范,需要检查以下地方,修改完毕重启sendmail即可

```bash
[root@ossec-server analogi-master]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.0.1 ossec-server.com
10.10.16.1 ossec-server.com
[root@ossec-server analogi-master]# cat /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=ossec-server.com
[root@ossec-server analogi-master]# hostname
ossec-server.com
```
