---
title: MySQL查询按IN的顺序输出结果
date: 2016-04-20
tags:
- mysql
- sql
categories:
 - Database
---




在用 SELECT 查询的时候，如果用到了 IN ，那么查询结果中的顺序并不是按照 IN 后面所给的顺序返回，而是按照默认的升序排列。

而如果想要让查询结果按照 IN 里面给的顺序的话，有最简单方法：

```sql
SELECT 
    * 
FROM
    a 
ORDER BY FIELD(
        id,
        '16556004',
        '16552005',
        '16558009',
        '16551033'
    )
```
