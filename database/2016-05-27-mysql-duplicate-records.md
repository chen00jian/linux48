---
title: MySQL查询表内重复记录
date: 2016-05-27
tags:
- mysql
- sql
categories:
 - Database
---



MySQL查询表内重复记录

```sql
-- 1.查找表中多余的重复记录，重复记录是根据单个字段（peopleId）来判断
select * from people
where peopleId in (select peopleId from people group by peopleId having count(peopleId) > 1)
 
-- 2.删除表中多余的重复记录，重复记录是根据单个字段（peopleId）来判断，只留有一个记录
delete from people
where peopleId in (select peopleId from people group by peopleId having count(peopleId) > 1)
and min(id) not in (select id from people group by peopleId having count(peopleId )>1)
 
-- 3.查找表中多余的重复记录（多个字段）
select * from vitae a
where (a.peopleId,a.seq) in (select peopleId,seq from vitae group by peopleId,seq having count(*) > 1)
 
-- 4.删除表中多余的重复记录（多个字段），只留有rowid最小的记录
delete from vitae a
where (a.peopleId,a.seq) in (select peopleId,seq from vitae group by peopleId,seq having count(*) > 1)
and rowid not in (select min(rowid) from vitae group by peopleId,seq having count(*)>1)
 
-- 5.查找表中多余的重复记录（多个字段），不包含rowid最小的记录
select * from vitae a
where (a.peopleId,a.seq) in (select peopleId,seq from vitae group by peopleId,seq having count(*) > 1)
and rowid not in (select min(rowid) from vitae group by peopleId,seq having count(*)>1)
```



eg :

在A表中存在一个字段“name”，
而且不同记录之间的“name”值有可能会相同，
现在就是需要查询出在该表中的各记录之间，“name”值存在重复的项；

```sql
Select Name,Count(*) From A Group By Name Having Count(*) > 1
```

如果还查性别也相同大则如下:

```sql
Select Name,sex,Count(*) From A Group By Name,sex Having Count(*) > 1
```
