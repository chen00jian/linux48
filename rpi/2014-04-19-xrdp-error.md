---
title: XRDP远程登树莓派出错
date: 2014-04-19
tags:
- RaspberryPi
categories:
 - RaspberryPi
---



由于很久没有玩我的小派了，今天插上去首先就想图形界面看看

mstsc远程登录树莓派，界面选择sesman-Xvnc，输入用户名密码登录

登录提示如下：

```bash
connecting to sesman ip 127.0.0.1 port 3350
sesman connect ok
sending login info to sesman 
login successful for display 14
started connecting
connecting to 127.0.0.1 5910
error - problem connecting 
```

查看5910和3389端口

```bash
pi@raspberrypi ~ $ netstat -tnl                    
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 0.0.0.0:9091            0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:3306          0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:51413           0.0.0.0:*               LISTEN         
tcp        0      0 127.0.0.1:3350          0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:3389            0.0.0.0:*               LISTEN   
```

没发现5910端口

看一下xrdp-sesman.log就知道了，注意：你要至少远程过一次，才会有以下的错误信息。

```bash
pi@raspberrypi ~ $ sudo vim /var/log/xrdp-sesman.log
[20140419-17:56:10] [ERROR] X server for display 10 startup timeout
[20140419-17:56:10] [INFO ] starting xrdp-sessvc - xpid=3054 - wmpid=3053
[20140419-17:56:10] [ERROR] X server for display 10 startup timeout
[20140419-17:56:10] [ERROR] another Xserver is already active on display 10
[20140419-17:56:10] [DEBUG] aborting connection...
[20140419-17:56:10] [INFO ] session 3052 - user pi - terminated
[20140419-17:56:50] [INFO ] scp thread on sck 7 started successfully
[20140419-17:57:01] [INFO ] scp thread on sck 7 started successfully
[20140419-17:57:01] [INFO ] granted TS access to user pi
[20140419-17:57:01] [INFO ] starting Xvnc session...
[20140419-17:57:01] [CORE ] error starting X server - user pi - pid 3076
[20140419-17:57:01] [DEBUG] errno: 2, description: No such file or directory
[20140419-17:57:01] [DEBUG] execve parameter list: 13
```

发现vnc有问题，于是乎就在装一下vnc看看

```bash
pi@raspberrypi ~ $ sudo apt-get install tightvncserver xrdp
```

然后查看5910端口是否启动

```bash
pi@raspberrypi ~ $ netstat -tnl|grep 5910
tcp        0      0 0.0.0.0:5910            0.0.0.0:*               LISTEN    
```

继续mstsc成功连接树莓派图形化界面！

参考ubuntu论坛连接 [http://forum.ubuntu.org.cn/viewtopic.php?t=342837](http://forum.ubuntu.org.cn/viewtopic.php?t=342837)

https://blog.csdn.net/u011816696/article/details/73350931

