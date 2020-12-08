---
title: mysql_glibc安装
date: 2017-11-29
tags:
- mysql
categories:
 - Database
---

# 用于快速部署分库环境  无需root权限  比多实例（mysqld_multi）配置快速

# 安装mysql_glibc，解压启动即可


```bash
wget http://mirrors.sohu.com/mysql/MySQL-5.5/mysql-5.5.55-linux2.6-x86_64.tar.gz
# 其他版本也可以下载glibc
# wget http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-x86_64.tar.gz
tar zxvf mysql-5.5.55-linux2.6-x86_64.tar.gz
mv mysql-5.5.55-linux2.6-x86_64  /data
cd /data
chown -R xiaolei.xiaolei mysql-5.5.55-linux2.6-x86_64
cd mysql-5.5.55-linux2.6-x86_64
mkdir etc
cp support-files/my-medium.cnf  etc/my.cnf
vim etc/my.cnf
cd data/
pwd
cd ..
vim etc/my.cnf
chown -R xiaolei.xiaolei mysql-5.5.55-linux2.6-x86_64
su xiaolei
cd mysql-5.5.55-linux2.6-x86_64/
./scripts/mysql_install_db --basedir=/data/mysql-5.5.55-linux2.6-x86_64 --datadir=/data/mysql-5.5.55-linux2.6-x86_64/data --defaults-file=etc/my.cnf
#./bin/mysqld --defaults-file=/data/mysql-5.7.25-linux-glibc2.12-x86_64/etc/my.cnf --initialize-insecure --user=mysql --basedir=/data/mysql-5.7.25-linux-glibc2.12-x86_64  --datadir=/data/mysql-5.7.25-linux-glibc2.12-x86_64/data
./bin/mysqld_safe --defaults-file=etc/my.cnf
./bin/mysql -uroot -p -S data/mysql.sock 
SHOW VARIABLES LIKE 'socket';
grant all privileges on *.* to xiaolei @'10.10.3.%' identified by 'LXMQ#lxiaolei@ey' ;
flush privileges;
```

```bash
cat stat_mysql.sh
./bin/mysqld_safe --defaults-file=etc/my.cnf &
cat mysql.sh
/data/mysql-5.7.25-linux-glibc2.12-x86_64/bin/mysql -uroot -p -S /data/mysql-5.7.25-linux-glibc2.12-x86_64/data/mysql.sock
```


1、打开etc/my.cnf将client的socket路径和mysqld的socket路径都改为MySQL所在目录的var/mysql.sock。

2、启动

./bin/mysqld_safe --defaults-file=etc/my.cnf &

3、client连接

./bin/mysql -uroot -p -S var/mysql.sock 

4、重新初始化

./scripts/mysql_install_db --basedir=/data/mysql_int/mysql-5.5.46/ --datadir=/data/mysql_int/mysql-5.5.46/data

5.7初始化

./bin/mysqld --defaults-file=/dbbak/mysql-5.7.18-linux-glibc2.5-x86_64/etc/my.cnf --basedir=/dbbak/mysql-5.7.18-linux-glibc2.5-x86_64/ --datadir=/dbbak/mysql-5.7.18-linux-glibc2.5-x86_64/data/ --initialize


```bash
[xiaolei@3-225 mysql_int]$ ll
总用量 16
drwxrwxr-x. 17 xiaolei xiaolei 4096 5月  26 17:58 m1
drwxrwxr-x. 17 xiaolei xiaolei 4096 5月  27 14:01 m2
drwxrwxr-x. 17 xiaolei xiaolei 4096 5月  27 14:01 s1
drwxrwxr-x. 17 xiaolei xiaolei 4096 5月  27 14:01 s2
[xiaolei@3-225 mysql_int]$ 
[xiaolei@3-225 mysql_int]$ 
[xiaolei@3-225 mysql_int]$ ps -ef |grep `pwd`
xiaolei   7420  7180  0 14:07 pts/2    00:00:00 /data/mysql_int/m1/bin/mysqld --defaults-file=etc/my.cnf --basedir=/data/mysql_int/m1 --datadir=/data/mysql_int/m1/data --plugin-dir=/data/mysql_int/m1/lib/plugin --log-error=/data/mysql_int/m1/data/3-225.err --pid-file=/data/mysql_int/m1/data/3-225.pid --socket=/data/mysql_int/m1/var/mysql.sock --port=8306
xiaolei   7959  7721  0 14:08 pts/2    00:00:00 /data/mysql_int/m2/bin/mysqld --defaults-file=etc/my.cnf --basedir=/data/mysql_int/m2 --datadir=/data/mysql_int/m2/data --plugin-dir=/data/mysql_int/m2/lib/plugin --log-error=/data/mysql_int/m2/data/3-225.err --pid-file=/data/mysql_int/m2/data/3-225.pid --socket=/data/mysql_int/m2/var/mysql.sock --port=8307
xiaolei   8527  8289  0 14:08 pts/2    00:00:00 /data/mysql_int/s1/bin/mysqld --defaults-file=etc/my.cnf --basedir=/data/mysql_int/s1 --datadir=/data/mysql_int/s1/data --plugin-dir=/data/mysql_int/s1/lib/plugin --log-error=/data/mysql_int/s1/data/3-225.err --pid-file=/data/mysql_int/s1/data/3-225.pid --socket=/data/mysql_int/s1/var/mysql.sock --port=9306
xiaolei   8791  8551  0 14:09 pts/2    00:00:00 /data/mysql_int/s2/bin/mysqld --defaults-file=etc/my.cnf --basedir=/data/mysql_int/s2 --datadir=/data/mysql_int/s2/data --plugin-dir=/data/mysql_int/s2/lib/plugin --log-error=/data/mysql_int/s2/data/3-225.err --pid-file=/data/mysql_int/s2/data/3-225.pid --socket=/data/mysql_int/s2/var/mysql.sock --port=9307
xiaolei   8962  3226  0 14:09 pts/2    00:00:00 grep --color=auto /data/mysql_int
[xiaolei@3-225 mysql_int]$ 
```

# 快速搭建主从环境

```sql
GRANT REPLICATION SLAVE ON *.* TO 'replication'@'localhost' IDENTIFIED BY 'Ebuy2012';
FLUSH PRIVILEGES;

m1--8306
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000005 |      107 |              |                  |
+------------------+----------+--------------+------------------+


m2--8307

+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000005 |      107 |              |                  |
+------------------+----------+--------------+------------------+

s1--9306
s2--9307

stop slave;
CHANGE MASTER TO MASTER_HOST='localhost';
CHANGE MASTER TO MASTER_PORT=8307;
CHANGE MASTER TO MASTER_USER='replication';
CHANGE MASTER TO MASTER_PASSWORD='Ebuy2012';
CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000005', MASTER_LOG_POS=107;
start slave;
show slave status\G;

```

# 导入数据

```bash
[root@3-225 mysql_int]# ./m1/bin/mysql -uroot -p -S ./m1/var/mysql.sock  < /data/data/ebuyweb_posp-2017-05-23.sql 
Enter password: 
[root@3-225 mysql_int]# 
[root@3-225 mysql_int]# ./m2/bin/mysql -uroot -p -S ./m2/var/mysql.sock  < /data/data/ebuyweb_posp-2017-05-23.sql   
Enter password: 
[root@3-225 mysql_int]# ./m1/bin/mysql -uroot -p -S ./m1/var/mysql.sock
mysql> SHOW VARIABLES LIKE 'socket';
+---------------+-----------------------------------+
| Variable_name | Value                             |
+---------------+-----------------------------------+
| socket        | /data/mysql_int/m1/var/mysql.sock |
+---------------+-----------------------------------+
1 row in set (0.00 sec)


```
