---
title: Mysql慢查询设置
date: 2019-07-12
tags:
- mysql
categories:
 - Database
---




有时候需要对sql语句进行优化，就需要查看慢查询语句  
``mysql>show variables like %slow%;`` 查看慢查询配置  
设置方法有下面两种：

1.进入mysql设置不用重启服务,但是重启mysql会失效  

```sql
mysql> set global log_slow_queries=on; #开启慢查询log  
mysql> set global slow_query_log_file=/data/mysql/mysql.slow.log; 指定log路径  
mysql> set global long_query_time=1; #设置超过1s的查询记录到log
```

2.修改my.cnf，需要重启mysql

5.0版  

```sql
log-slow-queries = /data/mysqldata/slowquery.log #日志目录  
long_query_time = 1 #记录下查询时间查过1秒  
log-queries-not-using-indexes #表示记录下没有使用索引的查询
```

5.1.29版後  

```sql
slow_query_log  
slow_query_log_file = /var/log/mysql-slow.log  
long_query_time = 5
```