---
title: mysql双主主键冲突排查修复
date: 2015-07-22
tags:
- mysql
categories:
 - Database
---




## 背景

线上A和B互为主主，A为业务写库，B为读库

19号下午收到短信报警A的slave delay，果断VPN上去数据库查看到

    Last_SQL_Error: Error 'Duplicate entry '4960446' for key 'transaction_id'' on query. Default database

又是熟悉的主键冲突，但是这个时候不能让业务出现任何问题，就果断在A



```bash
mysql> STOP SLAVE;
mysql> SET GLOBAL sql_slave_skip_counter = 1;
mysql> START SLAVE;
```

经过2次重复的上述操作，同步OK了，然后根据这两条报错的主键ID在两台数据库查询发现都不一样，
此时我清楚的知道已经有2条数据差异了，如果不及时处理早晚有一天被掩盖的问题会再次爆发出来。

后来经过一些列的排查之后知道问题所在了

因为7月2号晚上在B`alter`表的时候，导致B锁表，而A还在写入，并且正好在更新服务，导致数据的差异

查`general log`得知7月19号人为的在B上插入了两条`transaction_id="4960446"`和`transaction_id="4960426"`的记录和A的id冲突，导致A同步挂掉

因为A为业务写库，所以现在需要把A上这两条正确的数据插入到B，并在B上面删除错误的。

由于这个是自增的主键，所以还不好操作，下面大概就测试环境详细说明一下复现方案以及解决办法。



---------------------------------------------------------------------------


## 复现方案

>* 192.168.1.52  模拟线上A 负责写入
>* 192.168.1.42  模拟线上B 负责读取

### 设置my.cnf，差开自增ID

52配置

    auto-increment-increment=10
    auto-increment-offset=8


42配置

    auto-increment-increment=10
    auto-increment-offset=6


### 创建测试表

随便在其中一台的test库中创建测试表，双主自动同步到另一台

```sql
use test;

CREATE TABLE `test` (
  `qrpay_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `transaction_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`qrpay_id`),
  UNIQUE KEY `transaction_id` (`transaction_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=896 DEFAULT CHARSET=utf8;
```

### 插入测试数据

在52插入测试数据，可以发现"qrpay_id"的值是依照 auto-increment-offset 格式的, 同步过去也是如此

```bash
INSERT INTO `test` VALUES ('null','1');
INSERT INTO `test` VALUES ('null','2');
INSERT INTO `test` VALUES ('null','3');
```

   在42插入测试数据，可以发现"qrpay_id"的值是依照 auto-increment-offset 格式的, 同步过去也是如此

```bash
INSERT INTO `test` VALUES ('null','4');
INSERT INTO `test` VALUES ('null','5');
INSERT INTO `test` VALUES ('null','6');
```

### 模拟同步异常

停掉42的同步

    slave stop;

并在52上插入数据

    INSERT INTO `test` VALUES ('null','7');

在42上插入数据

    INSERT INTO `test` VALUES ('null','7');

开启42的同步

    slave start;

在两边都show slave status \G; 可以发现都提示

    Error 'Duplicate entry '7' for key 'transaction_id'' on query. Default database: 'test'. Query: 'INSERT INTO `test` VALUES ('null','7')'

因为停掉了42的同步，所以插入到52的数据不会同步到42，并且也在42上面插入了相同值的transaction_id，同步到52的时候就导致了主键重复，最后开启42的同步，双方都互相冲突

这个时候两边主从都是挂掉的，然后两边都跳过这个错误

    stop slave;
    set global sql_slave_skip_counter=1;
    slave start;

再show slave status \G;查看正常


### 模拟数据差异1

在42上面删掉transaction_id刚才冲突的那条transaction_id='7'的记录,按照qrpay_id找

    delete from test where qrpay_id='1166';


继续在52写入测试数据

```bash
INSERT INTO `test` VALUES ('null','8');
INSERT INTO `test` VALUES ('null','9');
INSERT INTO `test` VALUES ('null','10');
```

这个时候52上面比42的多了一条transaction_id='7'的记录

以上目地是模拟出真实数据库A比B多数据的场景


### 修复同步

在42上插入数据

    INSERT INTO `test` VALUES ('null','7');

这时因为52上已有transaction_id='7'的记录的值导致52同步挂掉

只有52报

    Error 'Duplicate entry '7' for key 'transaction_id'' on query. Default database: 'test'. Query: 'INSERT INTO `test` VALUES ('null','7')'


在52上跳过错误

    stop slave;
    set global sql_slave_skip_counter=1;
    slave start;

再show slave status \G;查看正常

52继续插入数据

```bash
INSERT INTO `test` VALUES ('null','11');
INSERT INTO `test` VALUES ('null','12');
INSERT INTO `test` VALUES ('null','13');
```

发现42也健康的同步过来了

### 复现完毕

 数据差异为transaction_id='7'这条记录,需要修复

-----------------------------------------------------

## 线上解决方案

### 备份线上数据表

晚上12点过后备份A和B的`test`表（需要恢复的表，为了隐私这里用test代替）

还好这张表里只有100多万条数据，很快就备份出来了，要不然备份锁表就不能这样搞了


### 导库到测试

次日上班处理

停掉测试环境52，42双方的slave

线上A备份导入到52的test库，线上B备份导入到42的test库,两个库的input_date框在同一时间,并比对一下条数记录是否一致


```bash
    delete from test where input_date >= '2015-07-22 00:00:00'
    select count(*) from test
```

双方重新 记录**`show master status`**的值  并**`change master`**

开启双方`slave`,这个时候双方的数据就有差异，而不会双向同步问题数据咯

### 修复数据

因为52和42是双主模式，具体正确数据以线上A导入到52的数据为准

在52上面执行下面命令，来检测数据的一致性

    pt-table-checksum --nocheck-replication-filters  --no-check-binlog-format  --replicate=test.checksums  --databases=test --tables=test  --host=localhost    --password=123456


```bash
tip:
参数解释
--nocheck-replication-filters ：不检查复制过滤器，建议启用。后面可以用--databases来指定需要检查的数据库。
--no-check-binlog-format      : 不检查复制的binlog模式，要是binlog模式是ROW，则会报错。
--replicate-check-only :只显示不同步的信息。
--replicate=   ：把checksum的信息写入到指定表中，建议直接写到被检查的数据库当中。 
--databases=   ：指定需要被检查的数据库，多个则用逗号隔开。
--tables=      ：指定需要被检查的表，多个用逗号隔开
h=127.0.0.1    ：Master的地址
u=root         ：用户名
p=123456       ：密码
P=3306         ：端口


输出解释
TS            ：完成检查的时间。
ERRORS        ：检查时候发生错误和警告的数量。
DIFFS         ：差异的条数。当指定--no-replicate-check时，会一直为0，当指定--replicate-check-only会显示不同的信息。
ROWS          ：表的行数。
CHUNKS        ：被划分到表中的块的数目。
SKIPPED       ：由于错误或警告或过大，则跳过块的数目。
TIME          ：执行的时间。
TABLE         ：被检查的表名。
```

由于线上A和B已经存在差异，所以肯定DIFFS是一个非0的值

需要在42创建checksum用户供52使用

    grant SELECT, PROCESS, SUPER, REPLICATION SLAVE on *.* to checksum @'192.168.1.52' identified by '123456' ;
    flush privileges;

在52执行下面命令，通过（--print）打印出需要修复数据的sql语句，然后记录下来，然后经过处理，手动的拿去线上B去行执行，让他们数据保持一致性

    pt-table-sync --replicate=test.checksums h=localhost,u=root,p=123456 h=192.168.1.42,u=checksum,p=123456 --print --charset=utf8


tip:为什么要print直接打印出来问题sql，这是因为pt-table-sync会重建数据，所以有一定的风险，最好提前备份好数据。如果仍然不放心，可以使用它提供的「print」选项，它会打印出相应的SQL，你可以审查一下到底执行了那些操作，然后通过手动执行来完成同步, **`--charset=utf8`**  这个参数是让打印出来的sql语句中的汉字正常显示，不然会是乱码。
    
    也可以通过(--execute)直接修复，但是建议千万不要这么做。


## 附：

-----------------Percona Toolkit INSTALL-------------------------


```bash
yum install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker -y
yum perl-DBD-MySQL -y
yum perl-Time-HiRes -y
yum perl-TermReadKey -y
yum perl-DBI


wget https://www.percona.com/downloads/percona-toolkit/2.2.14/tarball/percona-toolkit-2.2.14.tar.gz

tar zxvf percona-toolkit-2.2.14.tar.gz 
cd percona-toolkit-2.2.14
perl Makefile.PL PREFIX=/usr/local/percona-toolkit
make
make install
echo "PATH=$PATH:/usr/local/percona-toolkit" >> /etc/profile
echo "export PATH" >> /etc/profile
source /etc/profile
```
