---
title: MYSQL在一个字段值前面加字符串
date: 2015-07-30
tags:
- mysql
- sql
categories:
 - Database
---




```sql
--在`menber`表的`name`字段前面按照条件批量加`jc100`这个字符串

UPDATE 
    `usrdb`.`menber`
  SET
    `name` = CONCAT('jc100', `name`) 
  WHERE provice = '678' 
    AND input_time BETWEEN '2015-07-30 00:00:00' 
    AND '2015-07-30 23:59:59' 
```

mysql的**`CONCAT()`**函数用于将多个字符串连接成一个字符串，是最重要的mysql函数之一。



如果要在字段后面添加字符串则是这样写

```sql
UPDATE
    `usrdb`.`menber`
  SET
    `name` = CONCAT('name', `jc100`)
  WHERE provice = '678'
    AND input_time BETWEEN '2015-07-30 00:00:00'
    AND '2015-07-30 23:59:59'
```
