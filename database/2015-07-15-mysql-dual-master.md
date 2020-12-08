---
title: mysql双主互备设计搭建
date: 2015-07-15
tags:
- mysql
categories:
 - Database
---




:::tip 
Master-Master复制的两台服务器，既是master，又是另一台服务器的slave。这样，任何一方所做的变更，都会通过复制应用到另外一方的数据库中。
这样做的好很多，主要是下面几点:
>* 可以做灾备，其中一个坏了可以切换到另一个。 
>* 可以做负载均衡，可以将请求分摊到其中任何一台上，提高网站吞吐量。  
>* 对于异地热备，尤其适合灾备。
>* ...

:::

<!-- more -->

今天在测试环境部署一套下来，简单总结一下过程以及经验



过程大致和主从配置一样,此处就不在赘述

```
按照主从配置步骤将MasterB配置成MasterA的从库
```

```flow
op1=>operation: MASTER-A
op2=>operation: MASTER-B
op1->op2
```

```
确保MasterB没有写入，通过show master status命令在MasterB上得到其同步点，再将MasterA配置成MasterB的从库
```

```flow
op1=>operation: MASTER-A
op2=>operation: MASTER-B
op2->op1
```


因为每台数据库服务器都可能在同一个表中插入数据，如果表有一个自动增长的主键，那么就会在多服务器上出现主键冲突。解决这个问题的办法就是让每个数据库的自增主键不连续。为了避免自增id冲突，一般会设置下面两个参数

```
auto-increment-increment=10
#表示自增长字段从那个数开始，取值范围是1 .. 65535

auto-increment-offset=8
#表示自增长字段每次递增的量，其默认值是1，取值范围是1 .. 65535
```





**以下为48核，128G，SSD DB_SERVER的my.cnf配置**

>* MASTER-A

```
[ebuy@DB1 ~]$ cat /etc/my.cnf 
[client]
port            = 3306
socket          = /dbdata/mysqldata/mysql.sock


[mysqld]
port            = 3306
socket          = /dbdata/mysqldata/mysql.sock
skip-external-locking
key_buffer_size = 2G
max_allowed_packet = 100M
table_open_cache = 512
sort_buffer_size = 8M
read_buffer_size = 20M
join_buffer_size = 2M
read_rnd_buffer_size = 20M
myisam_sort_buffer_size = 128M

thread_cache_size = 100
query_cache_size = 100M
query_cache_limit = 2M
tmp_table_size=200M 


basedir = /usr/local/mysql
datadir = /dbdata/mysqldata

thread_concurrency = 6

skip_name_resolve = 1



log-bin=/dbbak/binlog/mysql-bin
expire_logs_days = 7
server-id       = 8820

log_slave_updates = on
replicate_wild_ignore_table = mysql.%
replicate_wild_ignore_table = test.%
sync_binlog = 1


relay-log = /dbbak/binlog/mysql-relay-bin
relay_log_index = /dbbak/binlog/mysql-relay-bin.index
binlog_format = mixed



 
innodb_data_file_path = ibdata1:1024M;ibdata2:1024M:autoextend
innodb_log_group_home_dir = /dbbak/binlog/
innodb_file_per_table = 1
innodb_buffer_pool_size = 96G
innodb_additional_mem_pool_size = 20M
innodb_log_file_size = 1G
innodb_log_buffer_size = 18M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50
innodb_io_capacity = 800

innodb_flush_method = O_DIRECT

auto-increment-increment=10
auto-increment-offset=6
concurrent_insert=2

default-time-zone       = "+8:00"
character_set_server =  utf8

max_connections = 16384
general-log = on
general_log_file = /dbbak/binlog/general.log
slow-query-log = on
long_query_time = 3
slow_query_log_file = /dbbak/binlog/slowquery_3.log
log-queries-not-using-indexes = true
max_connect_errors = 100000

[mysqldump]
quick
max_allowed_packet = 50M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
[ebuy@DB1 ~]$ 
```


>* MASTER-B

```
[ebuy@DB2 ~]$ cat /etc/my.cnf 
[client]
port            = 3306
socket          = /dbdata/mysqldata/mysql.sock


[mysqld]
port            = 3306
socket          = /dbdata/mysqldata/mysql.sock
skip-external-locking
key_buffer_size = 2G
max_allowed_packet = 100M
table_open_cache = 512
sort_buffer_size = 8M
read_buffer_size = 20M
join_buffer_size = 2M
read_rnd_buffer_size = 20M
myisam_sort_buffer_size = 128M

thread_cache_size = 100
query_cache_size = 100M
query_cache_limit = 2M
tmp_table_size=200M 


basedir = /usr/local/mysql
datadir = /dbdata/mysqldata

thread_concurrency = 6

skip_name_resolve = 1



log-bin=/dbbak/binlog/mysql-bin
expire_logs_days = 7
server-id       = 8821

log_slave_updates = on
replicate_wild_ignore_table = mysql.%
replicate_wild_ignore_table = test.%
sync_binlog = 1


relay-log = /dbbak/binlog/mysql-relay-bin
relay_log_index = /dbbak/binlog/mysql-relay-bin.index
binlog_format = mixed



 
innodb_data_file_path = ibdata1:1024M;ibdata2:1024M:autoextend
innodb_log_group_home_dir = /dbbak/binlog/
innodb_file_per_table = 1
innodb_buffer_pool_size = 96G
innodb_additional_mem_pool_size = 20M
innodb_log_file_size = 1G
innodb_log_buffer_size = 18M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50
innodb_io_capacity = 800

innodb_flush_method = O_DIRECT

auto-increment-increment=10
auto-increment-offset=8
concurrent_insert=2

default-time-zone       = "+8:00"
character_set_server =  utf8

max_connections = 16384
general-log = on
general_log_file = /dbbak/binlog/general.log
slow-query-log = on
long_query_time = 3
slow_query_log_file = /dbbak/binlog/slowquery_3.log
log-queries-not-using-indexes = true
max_connect_errors = 100000

[mysqldump]
quick
max_allowed_packet = 50M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
[ebuy@DB2 ~]$ 
```