---
title: 用二句Shell命令实现FTP批量上传文件夹
date: 2014-11-11
tags:
- shell
categories:
 - System
---




实现代码如下：

```bash
#!/bin/bash 
updir=/root/tmp   #要上传的文件夹
todir=tmp          #目标文件夹
ip=127.0.0.1      #服务器
user=username  #ftp用户名
password=passwd        #ftp密码
sss=`find $updir -type d -printf $todir/'%P\n'| awk '{if ($0 == "")next;print "mkdir " $0}'` 
aaa=`find $updir -type f -printf 'put %p %P \n'` 
ftp -nv $ip <<EOF 
user $user $password
type binary 
prompt 
$sss 
cd $todir 
$aaa 
quit 
EOF
```

简要说明:
核心思想:1.初始化上传目录结构

2.初始化目录之后就可以直接使用put命令上传文件了

3.主要还是使用ftp自身的命令

4.格式化输出(可看作是FTP的宏命令)

5.保守的重定向输入流

核心语句只有两句：

第一句：

    sss=`find /root/sk -type d -printf '%P\n'| awk '{if ($0 == "")next;print "mkdir " $0}'`

这句主要是使用find找出目录结构，然后格式化输出，最后就是添加到FTP初始化目录结构。

第二句：

    aaa=`find /root/sk -type f -printf 'put %p %P \n'`

这句主要是使用find找出非目录文件，然后格式化输出，最后就是在初始化目录之后可以直接使用put上传文件。

shell脚本进行sftp文件上传与下载

http://blog.csdn.net/u012204058/article/details/53160419

```bash
#!/bin/bash

#SFTP配置信息
#用户名
USER=test
#密码
PASSWORD=test123
#待上传文件根目录
SRCDIR=/home/mysql/sqllog
#FTP目录
DESDIR=/nas/sqllog
#IP
IP=127.0.0.1
#端口
PORT=22

#获取文件
cd ${SRCDIR} ;
#目录下的所有文件
FILES=`ls`
#修改时间在执行时间五分钟之前的xml文件
#FILES=`find ${SRCDIR} -mmin -50 -name '*.xml'`

for FILE in ${FILES}
do
    echo ${FILE}
#发送文件 (关键部分）
lftp -u ${USER},${PASSWORD} sftp://${IP}:${PORT} <<EOF
cd ${DESDIR}/
lcd ${SRCDIR}
put ${FILE}
by
EOF

done
```
