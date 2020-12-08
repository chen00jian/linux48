---
title: mysql求平均值、最小和总值
date: 2015-10-27
tags:
- mysql
- sql
categories:
 - Database
---




```bash
mysql> CREATE TABLE sales_rep(
    ->   employee_number INT,
    ->   surname VARCHAR(40),
    ->   first_name VARCHAR(30),
    ->   commission TINYINT
    -> );
Query OK, 0 rows affected (0.00 sec)

mysql> INSERT INTO sales_rep values(4,'Rive','Mongane',10);
Query OK, 1 row affected (0.00 sec)

mysql> INSERT INTO sales_rep values(5,'Smith','Mike',12);
Query OK, 1 row affected (0.00 sec)

mysql> SELECT AVG(commission) FROM sales_rep;
+-----------------+
| AVG(commission) |
+-----------------+
|         11.0000 |
+-----------------+
1 row in set (0.00 sec)
--//以上是AVG()函数的用法，可以换成MIN()、SUM()函数，用来求最小值，求和。

```
