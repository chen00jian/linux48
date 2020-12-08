---
title: 使用redis-rdb-tools分析Redis内存
date: 2018-11-15
tags:
- redis
- memory
categories:
 - Database
---



当一个项目中Redis缓存的数据量逐渐增大，Redis缓存的数据占用内存也会越来越大，当积累到一定程度由于`bgsave`的原因有很大可能导致`FORK`或者`OOM`从而影响线上业务

由于redis其中有很多很可能是价值不大的过期数据；所以必须要加以分析清理

前面写到过[zabbix使用自动发现规则自动化监控redis多实例][1]但是这也只是监控层面，还得必须加以分析才能得出结论哪些`key`可以清理

由于Redis是一个key-value数据库，所以对其中的数据进行分析没有mysql数据库那么直观。那么此时，我们需要`redis-rdb-tools`工具来分析Redis缓存中的哪些数据占用内存比较大，并结合项目实际的情况来分析这些数据存储的价值如何？从而作出具体删减数据的方案

闲话不多说直接开搞


```bash
pip install rdbtools python-lzf

rdb -c memory dump.rdb > memory.csv
```


使用Navicat把memory.csv导入mysql


此处需要分析的数据：

>* 每一种key所在用的总内存大小（size_in_bytes_sum）
>* 每一种key的总数（PS：因为有的key设计是前缀+用户id，这样的情况都属于一种key）（record_count）
>* 每一种key所在数据库（database）
>* 每一种key的数据类型（type）
>* 每一种key的编码类型（encoding）
>* 每一种key的名称（key）
>* 每一种key占用的平均内存大小（size_in_bytes_avg）
>* ......

```sql
mysql> SELECT CONCAT(TRUNCATE(SUM(size_in_bytes)/1024/1024,2),'MB') AS data_size FROM `memory`;
+-----------+
| data_size |
+-----------+
| 4322.63MB |
+-----------+
1 row in set (0.04 sec)
//可以看到内存占用总大小大概为4.3G和redis-info显示的一样


mysql> SELECT `key`,CONCAT(TRUNCATE(SUM(size_in_bytes)/1024/1024,2),'MB') AS data_size FROM `memory` GROUP BY `key` ORDER BY SUM(`size_in_bytes`) DESC limit 6;
+------------------------------------------+-----------+
| key                                      | data_size |
+------------------------------------------+-----------+
| CardNo.9458.49218.105499.2859.10311339   | 436.58MB  |
| CardNo.14488.83488.104299.2539.10308859  | 210.70MB  |
| CardNo.14488.83478.105519.2879.10311359  | 191.39MB  |
| CardNo.9078.49138.105489.2849.10311349   | 102.18MB  |
| CardNo.14488.501574.500263.2879.10311359 | 41.48MB   |
| Point:20170630                           | 33.70MB   |
+------------------------------------------+-----------+
//每一种key所用内存大小


mysql> SELECT COUNT(1) FROM `memory` WHERE `key` LIKE '%CardNo%';
+----------+
| COUNT(1) |
+----------+
|    76828 |
+----------+

......
```


  [1]: http://linux48.com/monitor/2017-02-28-zabbix-redis.html
