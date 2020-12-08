---
title: mysql取每隔一小时数据
date: 2015-10-21
tags:
- mysql
- sql
categories:
 - Database
---




```sql
SELECT 
    HOUR(`input_date`) AS HOUR,
    COUNT(1) AS 交易笔数,
    brand_name_cn AS 品牌,
    DATE_FORMAT(`input_date`, '%m%d') AS 交易日期 
FROM
    test.`1023` 
WHERE input_date >= 20150930000000 
    AND input_date <= 20150930235959 
    AND brand_name_cn = '统一星巴克' 
GROUP BY HOUR ;
```

格式化日期


```sql
SELECT 
    HOUR(`input_time`) AS HOUR,
    COUNT(1) AS COUNT
FROM
    `table_name` 
WHERE DATE_FORMAT(`input_time`, '%Y-%m-%d') = '2015-10-21' 
GROUP BY HOUR(`input_time`) ;
```
