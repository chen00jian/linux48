---
title: MySql中把一个表的数据插入到另一个表中的实现
date: 2014-07-25
tags:
- mysql
- sql
categories:
 - Database
---



1.如果2张表的字段一致，并且希望插入全部数据，可以用这种方法：

```sql
INSERT INTO 目标表 SELECT * FROM 来源表;
INSERT INSERT insertTest select * from insertTest2;
```

2.如果只希望导入指定字段，可以用这种方法：

```sql
INSERT INTO 目标表 (`字段1`, `字段2`, ...) SELECT `字段1`, `字段2`, ... FROM 来源表;(这里的话字段必须保持一致)
INSERT INSERT insertTest2(`id`) select `id` from insertTest2;
```

3.如果您需要只导入目标表中不存在的记录，可以使用这种方法：

```sql
INSERT INTO 目标表  
 (`字段1`, `字段2`, ...)  
 SELECT `字段1`, `字段2`, ...  
 FROM 来源表  
 WHERE not exists (select * from 目标表  
 where 目标表.比较字段 = 来源表.比较字段); 
   
 1>.插入多条记录：
insert into insertTest2
(`id`,`name`)
select `id`,`name`
from insertTest
where not exists (select * from insertTest2
where insertTest2.`id`=insertTest.id);
 
 2>.插入一条记录：
insert into insertTest    
(`id`, `name`)    
SELECT 100, 'liudehua'   
FROM dual    
WHERE not exists (select * from insertTest    
where insertTest.`id` = 100);
```