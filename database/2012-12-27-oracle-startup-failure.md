---
title: oracle startup failure
date: 2012-12-27
tags:
- oracle
categories:
 - Database
---



```
SQL> startup  
ORA-01078: failure in processing system parameters  
LRM-00109: could not open parameter file &#8216;/data/oracle/product/11.2.0/db_1/dbs/initORA10G.ora&#8217;
```

查找文件，不存在，估计是非法关机造成的。



**解决方法：**

将$ORACLE\_BASE/admin/数据库名称/pfile目录下的init.ora.012009233838形式的文件copy到$ORACLE\_HOME/dbs目录下initoracle.ora即可。（注：initoracle.ora中的oracle为你的实例名 即我的为 initora10g.ora）


```
[root@localhost dbs]# cp init.ora.721200911530 $ORACLE_HOME/dbs/initora10g.ora
```

然后继续切换到oracle 帐号,连接到 sqlplus,运行 startup