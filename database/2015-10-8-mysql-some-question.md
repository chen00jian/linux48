---
title: mysql You cant specify target table
date: 2015-10-08
tags:
- mysql
- sql
categories:
 - Database
---




今天在写SQL语句的时候遇到一个比较特殊的问题。
mysql 语句如下:

```sql
UPDATE 
  pms_project_product 
SET
  area_list = 
  (SELECT 
    area_list 
  FROM
    pms_project_product 
  WHERE activity_product_id = 48468),
  area_list_name = 
  (SELECT 
    area_list_name 
  FROM
    pms_project_product 
  WHERE activity_product_id = 48468) 
WHERE activity_product_id = 47098 ;
```



运行时提出如下提示： ** You can't specify target table 'pms_project_product' for update in FROM clause **

运行 set 里面的 select 语句:

```sql
SELECT
         area_list
       FROM
         pms_project_product
       WHERE activity_product_id = 48468
```

可以正确 select 正确结果。再把结果直接写到 ** SET area_list = **里面，改后语句如下：

```sql
UPDATE 
  pms_project_product 
SET
  area_list = (***),
  area_list_name = (***) 
WHERE activity_product_id = 47098
```

再运行可以正确执行更新。

原因是：mysql中不能这么用。 （等待mysql升级吧）。那串英文错误提示就是说，不能先select出同一表中的某些值，

再update这个表(在同一语句中)。 于是我打算改用临时表的方案。

改写后的 sql 如下所示，大家仔细区别一下。

```sql
UPDATE 
  pms_project_product 
SET
  area_list = 
  (SELECT 
    tmp1.area_list 
  FROM
    (SELECT * FROM pms_project_product) tmp1
  WHERE tmp1.activity_product_id = 48468),
  area_list_name = 
  (SELECT 
    tmp2.area_list_name 
  FROM
    (SELECT * FROM pms_project_product) tmp2 
  WHERE tmp2.activity_product_id = 48468) 
WHERE activity_product_id = 47098
```

也就是说将select出的结果再通过临时表在select一遍，这样就规避了错误。注意，这个问题只出现于mysql，mssql和oracle不会出现此问题。
