---
title: case when遇上sum或count
date: 2019-10-17
tags:
- mysql
- sql
categories:
 - Database
---


>* 每日凌晨12点后统计前一天的数据汇总；并生成统计到一个新的表中

新表需求字段如下

| 字段    | 解释   |  eg  |  备注  |
| :-----: | :-----:  | :----:  | :----:  |
| StatisticalTime  |  昨天    |  20191015   |  昨天   |
| ticket_id　|  ticket_id   |  1000000006100   |  ticket_id   |
| SaleNum   |  售卖总数量   |  120   |  sta IN ('00', '01', '05', '08')    |
| VerifyNum   |  核销数量   |  30   |  sta='01'   |
| RefundNum   |  退款数量   |  30   |  sta='05'   |
| UnusedNum   |  未使用数量   |  30   |  sta='00'   |
| ActFailNum   |  未激活数量   |  30   |  sta='08'   |



::: tip
需要按５个维度来分组，求出按这５个维度分组的总数情况`count`，但同时也需要在这５个维度下求出按不同条件得出的总数，这些不同条件下分别得出的总数相加的和即为不加上条件的情况下的总数
即
``SaleNum＝VerifyNum＋RefundNum＋UnusedNum＋ActFailNum``
:::


需求SQL

``` sql
CREATE TABLE `statistics` (
    `StatisticalTime` CHAR(14) NOT NULL,
    `ticket_id` CHAR(14) NOT NULL,
    `SaleNum` CHAR(20) NOT NULL,
    `VerifyNum` CHAR(20) NOT NULL,
    `RefundNum` CHAR(14) NOT NULL,
    `UnusedNum` CHAR(14) NOT NULL,
    `ActFailNum` CHAR(14) NOT NULL
) ENGINE = INNODB DEFAULT CHARSET = utf8;



INSERT INTO statistics
SELECT 
    DATE_FORMAT(update_date,'%Y%m%d') AS StatisticalTime,
    ticket_id,
    COUNT(1) AS SaleNum,
    COUNT( CASE WHEN sta='01' THEN 1 ELSE NULL END ) AS VerifyNum,
    COUNT( CASE WHEN sta='05' THEN 1 ELSE NULL END ) AS RefundNum,
    COUNT( CASE WHEN sta='00' THEN 1 ELSE NULL END ) AS UnusedNum,
    COUNT( CASE WHEN sta='08' THEN 1 ELSE NULL END ) AS ActFailNum
FROM
    order
WHERE sta IN ('00', '01', '05', '08') 
    AND DATEDIFF(update_date,NOW())=-1
GROUP BY 
    ticket_id;
```

生成表格如下：

|StatisticalTime    | ticket_id    | SaleNum    | VerifyNum    | RefundNum    | UnusedNum    | ActFailNum  |
| :-----: | :-----:  | :----:  | :----:  | :----:  | :----:  | :----:  |
|20191015  | 1000000006144  | 905  | 276  | 0  | 629  | 0  |
|20191015  | 1000000006145  | 140  | 0  | 0  | 140  | 0  |
|20191015  | 1000000006146  | 2000  | 0  | 0  | 2000  | 0  |
|20191015  | 1000000006147  | 57  | 0  | 0  | 57  | 0  |
|20191015  | 1000000006148  | 2292  | 1445  | 0  | 847  | 0  |
|20191015  | 1000000006149  | 944  | 0  | 0  | 944  | 0  |
|20191015  | 1000000006150  | 144  | 20  | 0  | 124  | 0  |
|20191015  | 1000000006151  | 893  | 458  | 0  | 435  | 0  |
|20191015  | 1000000006152  | 1366  | 434  | 0  | 932  | 0  |


之后就是加定时每天0点过后跑。

参考
https://www.iteye.com/blog/raising-2280269

