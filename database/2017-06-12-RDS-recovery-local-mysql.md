---
title: RDS备份文件恢复到自建数据库
date: 2017-06-12
tags:
- mysql
- RDS
categories:
 - Database
---


## 安装启动mysql数据库

在进行RDS本地恢复数据之前，我们需要先在本地服务器上安装mysql的5.6版本，因为RDS是5.6版本，所以我们本地的mysql数据库要与RDS版本对应。

以下为了省去编译安装mysql,采取了使用`mysql_glibc`二进制免编译快速安装启动


```bash
wget http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz

# wget http://mirrors.sohu.com/mysql/MySQL-5.5/mysql-5.5.55-linux2.6-x86_64.tar.gz

tar zxvf mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz

chown -R xiaolei.xiaolei mysql-5.6.35-linux-glibc2.5-x86_64

su xiaolei

cd mysql-5.6.35-linux-glibc2.5-x86_64

mkdir etc

cp support-files/my-default.cnf  etc/my.cnf

cat etc/my.cnf  |grep -v "#"

[mysqld]
port = 8888
server_id = 8888
socket = /data/mysql-5.6.36-linux-glibc2.5-x86_64/data/mysql.sock
default-storage-engine=INNODB
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES


./scripts/mysql_install_db --basedir=/data/mysql-5.6.35-linux-glibc2.5-x86_64 --datadir=/data/mysql-5.6.35-linux-glibc2.5-x86_64/data --defaults-file=etc/my.cnf

./bin/mysqld_safe --defaults-file=etc/my.cnf

./bin/mysql -uroot -p -S data/mysql.sock 

SHOW VARIABLES LIKE 'socket';
```

## 下载RDS备份

登陆阿里云RDS控制台自行下载

下载下来解压可以很明显的看出，RDS是通过`percona-Xtrabackup`进行全量物理备份的

## 上传备份至本地mysql的data目录

停止本地mysqld

清空本地data目录

```bash
rm -rf /data/mysql-5.6.36-linux-glibc2.5-x86_64/data/*
```

上传RDS备份至本地mysql的data目录

## 启动本地mysqld查看数据

```bash
./bin/mysqld_safe --defaults-file=etc/my.cnf
./bin/mysql  -uroot -p -h 127.0.0.1 -P 8888
## RDS本地是没有root密码的
show databases;
use xxx;
select * from xxx;
```


参考：

http://www.cnblogs.com/ilanni/archive/2016/02/25/5218129.html

https://help.aliyun.com/knowledge_detail/41817.html

