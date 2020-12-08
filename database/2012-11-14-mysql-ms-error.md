---
title: MYSQL主从同步故障事件
date: 2012-11-14
tags:
- mysql
categories:
 - Database
---



```bash
show slave status \G;
... 1062error  
stop slave;  
set global sql_slave_skip_counter=1; ##1是指跳过一个错误 
slave start;  
show slave status \G;  ##查看正常
```

强制跳过1062错误了，修改从库的/etc/my.cnf文件  
在[mysqld]下面加入了一行  
``slave-skip-errors = 1062`` (忽略所有的1062错误)

注：此法只能应急，造成的后果是主从数据差异，如果对于数据一致性要求极高的，请不要使用此方案！切记！！
