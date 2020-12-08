---
title: msmtp+mutt服务器批量发送邮件
date: 2014-04-18
tags:
- msmtp
- mutt
- mail
categories:
 - System
---



1.msmtp安装

```bash
wget http://downloads.sourceforge.net/msmtp/msmtp-1.4.32.tar.bz2?modtime=1217206451&big_mirror=0
tar jxvf msmtp-1.4.32.tar.bz2
cd msmtp-1.4.32
./configure --prefix=/usr/local/msmtp
make
make install
cd /usr/local/msmtp
mkdir etc log
cd etc
ln -s /usr/local/msmtp/bin/msmtp /usr/bin/msmtp
```

编辑配置文件

```bash
vi /usr/local/msmtp/etc/msmtprc
# Set default values for all following accounts.
defaults
logfile /usr/local/msmtp/log/msmtp.log
# The SMTP server of the provider.
account test
# SMTP邮件服务器地址
host smtp.xxx.com
# 发送的邮件e-mail
Email root@test.com
auth login
# 邮件服务器登录账号
user root@test.com
# 邮件服务器登陆密码
password
# Set a default account
account default : test
```

安装完成检测

查看msmtp配置
msmtp -P
测试msmtp安装是否成功

msmtp -S

msmtp 邮箱地址

查看/usr/local/msmtp/log/msmtp.log

2.安装mutt

```bash
yum -y install mutt
```


可以使用which mutt查看mutt安装的路径

编辑mutt配置文件：vi /etc/Muttrc

在最后添加以下几行

```bash
set from="发送邮件地址"
set sendmail="/usr/local/msmtp/bin/msmtp"
set use_from=yes
set realname="发送邮件地址"
set editor="vi"
```

保存退出，测试一下mutt是否有效

```bash
echo "测试" | mutt -s "测试" 测试邮件地址 -a 附件
```

3，shell配置

```bash
#/bin/sh
#调用mutt发送邮件
echo "Sending mail…"$(date  +’%Y-%m-%d_%H-%M-%S’)
filename="xxxxx"
subject="xxxxx"
filename="xxxxx"
echo "$content" | mutt -s "$subject" 邮件地址 -a $filename
echo "Sent OK"
```
