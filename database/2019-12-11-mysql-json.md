---
title: MySQL json解析
date: 2019-12-11
tags:
- mysql
- json
categories:
 - Database
---


之前遇到json报文的字段，使用SUBSTRING截取进行解析，如果报文是规则的那还可以使用此法

```sql
SUBSTRING(sale_verify.product_detail,49,6) AS goodsName
```

但是如果json报文长短不一不规则，那以上方案就不行了

MySQL在5.7.8开始对json原生支持，本文将对MySQL中json类型的查询语法简单说明


## JSON_EXTRACT提取JSON值

```sql
mysql> SELECT JSON_EXTRACT('{"id": 29, "name": "Taylor"}', '$.name');
+--------------------------------------------------------+
| JSON_EXTRACT('{"id": 29, "name": "Taylor"}', '$.name') |
+--------------------------------------------------------+
| "Taylor"                                               |
+--------------------------------------------------------+
1 row in set (0.05 sec)
```


```sql
CREATE TABLE `t_json` (
  `jdoc` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 
INSERT INTO t_json VALUES('{"key1":"value1","key2":"value2"}');
INSERT INTO t_json VALUES('{"key1":"value1","key2":"value2"}');
INSERT INTO t_json VALUES('{"key1":"value1","key2":"value2"}');
INSERT INTO t_json VALUES('[1,2]');
INSERT INTO t_json VALUES('"HELLO"');

mysql> INSERT INTO t_json VALUES("HELLO");
3140 - Invalid JSON text: "Invalid value." at position 0 in value for column 't_json.jdoc'.

mysql> SELECT * FROM `test3307`.t_json;
+--------------------------------------+
| jdoc                                 |
+--------------------------------------+
| {"key1": "value1", "key2": "value2"} |
| {"key1": "value1", "key2": "value2"} |
| {"key1": "value1", "key2": "value2"} |
| [1, 2]                               |
| "HELLO"                              |
+--------------------------------------+
5 rows in set (0.05 sec)

mysql> SELECT JSON_EXTRACT(t_json.jdoc, '$.key1')  FROM `test3307`.t_json;
+--------------------------------------+
| JSON_EXTRACT(t_json .jdoc, '$.key1') |
+--------------------------------------+
| "value1"                             |
| "value1"                             |
| "value1"                             |
| NULL                                 |
| NULL                                 |
+--------------------------------------+
5 rows in set (0.04 sec)
```
-------

## 实际应用

```sql
# sale_verify 表的 product_detail 字段存的json格式的报文

[{"goodsId":"010299","activityNo":"0058678","price":33,"goodsCategory":"138","quantity":1,"goodsName":"W-醇艺白咖啡"}]


# 去掉[] 格式化标准json
UPDATE `sale_verify` SET product_detail = REPLACE(product_detail, ']', '');
UPDATE `sale_verify` SET product_detail = REPLACE(product_detail, '[', '');

# 使用mysql5.7.8以上版本查询
SELECT  JSON_EXTRACT (`sale_verify`.product_detail, '$.price') AS price,
JSON_EXTRACT (`sale_verify`.product_detail, '$.goodsId') AS goodsId,
JSON_EXTRACT (`sale_verify`.product_detail, '$.goodsName') AS goodsName
   FROM `sale_verify` ;


# 更改字段类型，经测试不更改也可查询,只要字段符合json格式
ALTER TABLE `sale_verify` 
	CHANGE `product_detail` `product_detail` json NULL COMMENT '明细报文' AFTER `activity_product_id`;
```
----

参考

https://www.jianshu.com/p/25161add5e4b

