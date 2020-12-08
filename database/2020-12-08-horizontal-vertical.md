---
title: mysql中横表和竖表相互转换
date: 2020-12-08
tags:
- mysql
categories:
 - Database
---


## 竖表转横表

```sql
CREATE TABLE student (
    id VARCHAR (32) PRIMARY KEY,
    NAME VARCHAR (50) NOT NULL,
    SUBJECT VARCHAR (50) NOT NULL,
    result INT
) ;


INSERT INTO student (id, NAME, SUBJECT, result) VALUES ('0001', '小明', '语文', 83);
INSERT INTO student (id, NAME, SUBJECT, result) VALUES ('0002', '小明', '数学', 97);
INSERT INTO student (id, NAME, SUBJECT, result) VALUES ('0003', '小明', '英语', 93);
INSERT INTO student (id, NAME, SUBJECT, result) VALUES ('0004', '小白', '语文', 93);
INSERT INTO student (id, NAME, SUBJECT, result) VALUES ('0005', '小白', '数学', 93);
INSERT INTO student (id, NAME, SUBJECT, result) VALUES ('0006', '小白', '英语', 95);


select * from student;

+------+------+---------+--------+
| id   | name | subject | result |
+------+------+---------+--------+
| 0001 | 小明 | 语文    |     83 |
| 0002 | 小明 | 数学    |     97 |
| 0003 | 小明 | 英语    |     93 |
| 0004 | 小白 | 语文    |     93 |
| 0005 | 小白 | 数学    |     93 |
| 0006 | 小白 | 英语    |     95 |
+------+------+---------+--------+



SELECT NAME AS '姓名',
MAX(CASE SUBJECT WHEN '语文' THEN result ELSE 0 END) '语文',
MAX(CASE SUBJECT WHEN '数学' THEN result ELSE 0 END) '数学',
MAX(CASE SUBJECT WHEN '英语' THEN result ELSE 0 END) '英语'
FROM student GROUP BY NAME;

+------+------+------+------+
| 姓名 | 语文 | 数学 | 英语 |
+------+------+------+------+
| 小明 |   83 |   97 |   93 |
| 小白 |   93 |   93 |   95 |
+------+------+------+------+
```
 

## 横表数转竖表

```sql
CREATE TABLE student1 (
    id VARCHAR (32) PRIMARY KEY,
    姓名 VARCHAR (50) NOT NULL,
    语文 INT,
    数学 INT,
    物理 INT
) ;


INSERT INTO student1 (id, 姓名, 语文, 数学, 物理) VALUES ('0001','小张', 93, 84, 99);
INSERT INTO student1 (id, 姓名, 语文, 数学, 物理) VALUES ('0002','小马', 86, 92, 90);



select * from student1;

+------+------+------+------+------+
| id   | 姓名 | 语文 | 数学 | 物理 |
+------+------+------+------+------+
| 0001 | 小张 |   93 |   84 |   99 |
| 0002 | 小马 |   86 |   92 |   90 |
+------+------+------+------+------+




SELECT*FROM
(
  SELECT 姓名 AS NAME , '语文' AS SUBJECT , 语文 AS result FROM student1
  UNION ALL
  SELECT 姓名 AS NAME , '数学' AS SUBJECT , 数学 AS result FROM student1
  UNION ALL
  SELECT 姓名 AS NAME , '物理' AS SUBJECT , 物理 AS result FROM student1
) t
ORDER BY NAME;



+------+---------+--------+
| NAME | SUBJECT | result |
+------+---------+--------+
| 小张 | 数学    |     84 |
| 小张 | 物理    |     99 |
| 小张 | 语文    |     93 |
| 小马 | 物理    |     90 |
| 小马 | 语文    |     86 |
| 小马 | 数学    |     92 |
+------+---------+--------+
```
