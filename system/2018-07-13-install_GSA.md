---
title: 绿骨安全助手安装.md
date: 2018-07-13
tags:
- openvas
- GSA
categories:
 - System
---


# install  Greenbone Security Assistant (GSA)（绿骨安全助手）

https://forums.atomicorp.com/viewforum.php?f=31

```
Here are my updated install notes for OpenVAS 9 on CentOS 7.3.1611 (minimal install).
Hope someone finds it useful.  :shock: 

1) Disable SELINUX (edit /etc/selinux/config) and reboot
#SELINUX=enforcing
SELINUX=disabled


2) Update your CentOS installation and reboot if necessary
yum -y update


3) Install the follow packages
yum install -y wget bzip2 texlive net-tools alien gnutls-utils


4) Add Atomicorp repo (see https://wiki.atomicorp.com/wiki/index.php/Atomic)
wget -q -O - https://www.atomicorp.com/installers/atomic | sh


5) Install OpenVAS 9
yum install openvas -y


6) edit /etc/redis.conf. Add/uncomment the following
unixsocket /tmp/redis.sock
unixsocketperm 700


7) Restart Redis
systemctl enable redis && systemctl restart redis


8) openvas-setup
Follow instructions and remember your admin password. If rsync throws error, check that your network allows outgoing TCP 873 to internet


9) Open firewall port for tcp/9392
firewall-cmd --permanent --add-port=9392/tcp
firewall-cmd --reload
firewall-cmd --list-port

Go to https://<IP-ADDRESS>:9392 and login.

systemctl enable gsad.service
systemctl enable openvas-scanner.service
systemctl enable gvmd.service


systemctl restart gsad.service
systemctl restart openvas-scanner.service
systemctl restart gvmd.service


systemctl status gsad.service
systemctl status openvas-scanner.service
systemctl status gvmd.service

```

# update


```
yum update openvas

openvas-setup
```


# 由于软件强制更新之后不少bug，故采用docker部署历史稳定版本


https://www.freebuf.com/column/158357.html

https://blog.csdn.net/ywqingtian1/article/details/89925615

```bash
docker pull mikesplain/openvas:9
docker run -d -p 443:443 -p 9390:9390 -e PUBLIC_HOSTNAME=10.10.3.225 -v /etc/localtime:/etc/localtime --name openvas mikesplain/openvas:9
https://10.10.3.225
admin/admin

# 同步漏洞库（NVT）
docker exec -i -t $(docker ps |grep 'openvas'|awk '{print $1}') bash
greenbone-nvt-sync
greenbone-scapdata-sync
greenbone-certdata-sync

# 保存镜像
docker commit $(docker ps |grep 'openvas'|awk '{print $1}') ebuy_openvas:9
```

