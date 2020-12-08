---
title: Windows下MySQL无法区分大小写解决方案
date: 2014-07-31
tags:
- mysql
categories:
 - Database
---


# Windows下MySQL无法区分大小写解决方案

MySQL在Linux下数据库名、表名、列名、别名大小写规则：

> * 1、数据库名与表名是严格区分大小写
> * 2、表的别名是严格区分大小写
> * 3、列名与列的别名在所有的情况下均是忽略大小写的
> * 4、变量名也是严格区分大小写的

注意：
> * A、Linux下MySQL安装完后默认：区分表名的大小写，不区分列名的大小写
> * B、改变表名的大小写区分规则的方法：用root帐号登录，在/etc/my.cnf 或 /etc/mysql/my.cnf 中的[mysqld]后添加添加lower_case_table_names=1，重启MySQL服务，若设置成功，则不再区分表名的大小写。

###[ Windows ]下MySQL无法区分大小写解决方案

MySQL在Windows下数据库名、表名、列名、别名都不区分大小写。 
如果想大小写区分则在my.ini 里面的mysqld部分
加入 lower_case_table_names=0


**lower_case_table_names**参数详解：

`lower_case_table_names = 0`

其中 0：区分大小写，  1：不区分大小写