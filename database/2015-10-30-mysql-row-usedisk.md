---
title:  mysql中查看数据库中所有表的记录数
date: 2015-10-30
tags:
- mysql
- sql
categories:
 - Database
---


:::tip 
如果想知道MySQL数据库中每个表占用的空间、表记录的行数的话，可以打开MySQL的 information_schema 数据库查看明细。
:::

<!-- more -->


如果想知道MySQL数据库中每个表占用的空间、表记录的行数的话，可以打开MySQL的 information_schema 数据库。在该库中有一个 TABLES 表，这个表主要字段分别是：

>* TABLE_SCHEMA : 数据库名
>* TABLE_NAME：表名
>* ENGINE：所使用的存储引擎
>* TABLES_ROWS：记录数
>* DATA_LENGTH：数据大小
>* INDEX_LENGTH：索引大小

其他字段请参考MySQL的手册，一下是利用这几个字段查询详情演示，可以根据具体业务来自定义sql监控mysql的磁盘使用状态和数据库各个表的具体条数。




```sql
select table_schema,table_name,table_rows from tables where TABLE_SCHEMA='ebuydb' order by table_rows desc ;


--查询所有数据的大小
use information_schema;
select concat(round(sum(DATA_LENGTH/1024/1024), 2),'MB') as data from TABLES;

--查询单个库占用空间
select concat(round(sum(DATA_LENGTH/1024/1024), 2),'MB') as data from TABLES where TABLE_SCHEMA='ebuydb';



--数据库总所占空间

SELECT CONCAT(TRUNCATE(SUM(data_length)/1024/1024,2),'MB') AS data_size,
CONCAT(TRUNCATE(SUM(max_data_length)/1024/1024,2),'MB') AS max_data_size,
CONCAT(TRUNCATE(SUM(data_free)/1024/1024,2),'MB') AS data_free,
CONCAT(TRUNCATE(SUM(index_length)/1024/1024,2),'MB') AS index_size，
FROM information_schema.tables WHERE TABLE_SCHEMA = '数据库名';


--数据库表占用空间明细
SELECT TABLE_NAME, table_rows,
CONCAT(TRUNCATE(SUM(data_length)/1024/1024,2),'MB') AS data_size,
CONCAT(TRUNCATE(SUM(max_data_length)/1024/1024,2),'MB') AS max_data_size,
CONCAT(TRUNCATE(SUM(data_free)/1024/1024,2),'MB') AS data_free,
CONCAT(TRUNCATE(SUM(index_length)/1024/1024,2),'MB') AS index_size，
FROM information_schema.tables WHERE TABLE_SCHEMA = '数据库名'
group by TABLE_NAME   order by data_length desc;

--表所占空间

SELECT CONCAT(TRUNCATE(SUM(data_length)/1024/1024,2),'MB') AS data_size,
CONCAT(TRUNCATE(SUM(max_data_length)/1024/1024,2),'MB') AS max_data_size,
CONCAT(TRUNCATE(SUM(data_free)/1024/1024,2),'MB') AS data_free,
CONCAT(TRUNCATE(SUM(index_length)/1024/1024,2),'MB') AS index_size
FROM information_schema.tables WHERE TABLE_NAME = '表名';


--查看指定数据库的表的大小，比如说数据库 forexpert 中的 member 表 

select concat(round(sum(DATA_LENGTH/1024/1024),2),'MB')as data
from TABLES where table_schema='test'
and table_name='1023';


mysql> select TABLE_NAME, concat(truncate(data_length/1024/1024,2),' MB') as data_size,   concat(truncate(index_length/1024/1024,2),' MB') as index_size   from information_schema.tables where TABLE_SCHEMA = 'test'   group by TABLE_NAME   order by data_length desc;         
+-------------------------+-----------+------------+
| TABLE_NAME              | data_size | index_size |
+-------------------------+-----------+------------+
| 1023                    | 152.68 MB | 0.00 MB    |
| gc1_3                   | 18.54 MB  | 9.54 MB    |
| gc6_8                   | 14.51 MB  | 7.51 MB    |
| gc4_5                   | 12.51 MB  | 6.51 MB    |
| tongyi1_3               | 11.51 MB  | 5.51 MB    |
| tongyi6_8               | 9.51 MB   | 4.51 MB    |
| tongyi4_5               | 8.51 MB   | 4.51 MB    |
| 1023_2                  | 1.51 MB   | 0.00 MB    |
| code                    | 0.14 MB   | 0.09 MB    |
| 1023_3                  | 0.06 MB   | 0.00 MB    |
+-------------------------+-----------+------------+
10 rows in set (0.01 sec)


mysql> select TABLE_SCHEMA, concat(truncate(sum(data_length)/1024/1024,2),' MB') as data_size,   concat(truncate(sum(index_length)/1024/1024,2),'MB') as index_size   from information_schema.tables  group by TABLE_SCHEMA  order by data_length desc;  

+-------------------------+--------------+------------+
| TABLE_SCHEMA            | data_size    | index_size |
+-------------------------+--------------+------------+
| test                    | 234.68 MB    | 39.42MB    |
| zabbix                  | 1.78 MB      | 2.70MB     |
| information_schema      | 0.00 MB      | 0.00MB     |
| performance_schema      | 0.00 MB      | 0.00MB     |
| mysql                   | 0.58 MB      | 0.10MB     |
+-------------------------+--------------+------------+
5 rows in set (0.54 sec)

--查看更加明细
mysql> USE information_schema;
Database changed
mysql> SELECT TABLE_NAME, table_rows,
    -> CONCAT(TRUNCATE(SUM(data_length)/1024/1024,2),'MB') AS data_size,
    -> CONCAT(TRUNCATE(SUM(max_data_length)/1024/1024,2),'MB') AS max_data_size,
    -> CONCAT(TRUNCATE(SUM(data_free)/1024/1024,2),'MB') AS data_free,
    -> CONCAT(TRUNCATE(SUM(index_length)/1024/1024,2),'MB') AS index_size
    -> FROM information_schema.tables  WHERE TABLE_NAME NOT LIKE "%history"
    -> AND TABLE_SCHEMA = 'test'
    -> GROUP BY TABLE_NAME   ORDER BY data_length DESC;
+-------------------------+------------+-----------+---------------+-----------+------------+
| TABLE_NAME              | table_rows | data_size | max_data_size | data_free | index_size |
+-------------------------+------------+-----------+---------------+-----------+------------+
| 1023                    |    3351704 | 152.68MB  | 0.00MB        | 7.00MB    | 0.00MB     |
| gc1_3                   |     323649 | 18.54MB   | 0.00MB        | 4.00MB    | 9.54MB     |
| gc6_8                   |     256131 | 14.51MB   | 0.00MB        | 4.00MB    | 7.51MB     |
| gc4_5                   |     219582 | 12.51MB   | 0.00MB        | 4.00MB    | 6.51MB     |
| tongyi1_3               |     184609 | 11.51MB   | 0.00MB        | 4.00MB    | 5.51MB     |
| tongyi6_8               |     150028 | 9.51MB    | 0.00MB        | 4.00MB    | 4.51MB     |
| tongyi4_5               |     132087 | 8.51MB    | 0.00MB        | 4.00MB    | 4.51MB     |
| 1023_2                  |      14619 | 1.51MB    | 0.00MB        | 4.00MB    | 0.00MB     |
| code                    |       2241 | 0.14MB    | 0.00MB        | 0.00MB    | 0.09MB     |
| 1023_3                  |        833 | 0.06MB    | 0.00MB        | 0.00MB    | 0.00MB     |
+-------------------------+------------+-----------+---------------+-----------+------------+
10 rows in set (0.01 sec)

mysql> 

```

参考：

BYTE(B):字节
1KB ，2 的 10 次方 ： 1024 BYTE.
1MB ，2 的 20 次方 ： 1024 KB.
1GB ，2 的 30 次方 ： 1024 MB.
1TB ，2 的 40 次方 ： 1024 GB.
1PB ，2 的 50 次方 ： 1024 TB.
1EB ，2 的 60 次方 ： 1024 PB.
1ZB ，2 的 70 次方 ： 1024 EB.
1YB ，2 的 80 次方 ： 1024 ZB.

