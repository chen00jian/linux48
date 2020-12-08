---
title: Crontab导致Linux的线程数枯竭
date: 2014-11-12
tags:
- crontab
- sendmail
- posfix
- postdrop
categories:
 - System
---




## 症状描述：

    ps -ef |grep sendmail 满屏
    ps -ef |grep postdrop 满屏

查看log疯狂刷屏

```bash
[root@10-10-11-141 runtime]# tail -f /var/log/maillog
Nov 12 18:00:24 10-10-11-141 postfix/postdrop[3804]: warning: mail_queue_enter: create file maildrop/634461.3804: No such file or directory
Nov 12 18:00:24 10-10-11-141 postfix/postdrop[4147]: warning: mail_queue_enter: create file maildrop/634601.4147: No such file or directory
Nov 12 18:00:24 10-10-11-141 postfix/postdrop[1741]: warning: mail_queue_enter: create file maildrop/634604.1741: No such file or directory
Nov 12 18:00:24 10-10-11-141 postfix/postdrop[1967]: warning: mail_queue_enter: create file maildrop/843229.1967: No such file or directory
Nov 12 18:00:25 10-10-11-141 postfix/postdrop[3244]: warning: mail_queue_enter: create file maildrop/135131.3244: No such file or directory
Nov 12 18:00:25 10-10-11-141 postfix/postdrop[2514]: warning: mail_queue_enter: create file maildrop/135247.2514: No such file or directory
```

同时``/var/spool/postfix/maildrop/``文件夹下出现大量簇文件

## 解决

使用``pstree|grep crond``，结果如下：

     |-crond---125*[crond---sendmail---postdrop]  

可见crond守护进程启动了sendmail，进而启动了postdrop。查看crond的配置， crontab -e，都没有发现几秒就启动的程序，所以可能是sendmail自己一旦邮件发送不成功，就持续重新发送而导致持续启动postdrop，而postdrop总是执行失败，导致持续写入日志到日志文件。日志文件增大的速率超过了logrotate的删除频率，所以占据了100%的磁盘空间。并且线程数也不断的增加。

首先停掉posfix `/etc/init.d/posfix stop`并删除``/var/spool/postfix/maildrop/``下面的全部簇文件，释放磁盘inode！

然后就是手起刀落干掉sendmail和postdrop的进程，注意先干掉postdrop子进程

    kill -9 $(ps -auwx | grep postdrop | gawk -F' ' '{print $2}')
    kill -9 $(ps -auwx | grep sendmail | gawk -F' ' '{print $2}')

之后还要设置crond的MAILTO为空

```bash
[root@10-10-11-141 runtime]# cat /etc/cron.d/0hourly 
MAILTO=""
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
HOME=/
01 * * * * root run-parts /etc/cron.hourly
```

```bash
[root@10-10-11-141 runtime]# cat /etc/crontab 
MAILTO=""
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
HOME=/

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed

[root@10-10-11-141 runtime]# service crond restart
```

最后整个世界都清静了！
