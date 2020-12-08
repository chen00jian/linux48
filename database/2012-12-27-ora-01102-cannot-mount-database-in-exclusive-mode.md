---
title: cannot mount database in EXCLUSIVE mode
date: 2012-12-27
tags:
- oracle
categories:
 - Database
---


ORA-01102: cannot mount database in EXCLUSIVE mode

还是startup的问题，真是连锁反应啊~~

```bash
SQL> conn /as sysdba
Connected to an idle instance.
SQL> startup
ORACLE instance started.
Total System Global Area  591396864 bytes
Fixed Size                   1220724 bytes
Variable Size             167776140 bytes
Database Buffers         415236096  bytes
Redo Buffers                 7163904 bytes
ORA-01102: cannot mount database in EXCLUSIVE mode
SQL> shutdown immediate
ORA-01507: database not mounted

ORACLE instance shut down.
```

去CSDN查了一下资料，终于解决了
出现ORA-1102错误可能有以下几种可能：
一、在HA系统中，已经有其他节点启动了实例，将双机共享的资源（如磁盘阵列上的裸设备）占用了；
二、说明Oracle被异常关闭时，有资源没有被释放，一般有以下几种可能，
1、 Oracle的共享内存段或信号量没有被释放；
2、 Oracle的后台进程（如SMON、PMON、DBWn等）没有被关闭；
3、 用于锁内存的文件lk和sgadef.dbf文件没有被删除。
第一点，可以通过在备节点上查数据库状态来判断是否已启动实例。
第二点，如果系统是因为断电引起数据库宕机的，并且系统在接电被重启后，我们可以排除第二种可能的1、2点。接下来考虑第3点。

```bash
查$ORACLE_HOME/dbs目录：
[oracle@localhost dbs]$ ls sgadef*
ls: cannot access sgadef*: No such file or directory
[oracle@localhost dbs]$ ls lk*
lkORCL
[oracle@localhost dbs]$
lk文件没有被删除。将它删除掉

[oracle@localhost dbs]$ rm lkORCL
再启动数据库，成功。
```

如果是Oracle进程没有关闭，用以下命令查出存在的oracle进程：

```bash
[root@localhost dbs]# ps -ef|grep oracle
root      2310  2358  0 16:00 pts/0    00:00:00 su - oracle
oracle    2311  2310  0 16:00 pts/0    00:00:00 -bash
root      2427  2403  0 10:47 pts/1    00:00:00 su - oracle
```
 

然后用kill -9命令杀掉进程
$kill -9
总结：
当发生1102错误时，可以按照以下流程检查、排错：
1.如果是HA系统，检查其他节点是否已经启动实例；

2.检查Oracle进程是否存在，如果存在则杀掉进程；

3.检查信号量是否存在，如果存在，则清除信号量；

4.检查共享内存段是否存在，如果存在，则清除共享内存段；

5.检查锁内存文件lk和sgadef.dbf是否存在，如果存在，则删除。
