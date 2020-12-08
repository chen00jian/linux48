---
title: oracle startup
date: 2012-12-27
tags:
- oracle
categories:
 - Database
---


# oracle startup 故障：ORA-00845: MEMORY_TARGET


书接上文，oracle startup上文报错解决之后又出现此问题

Oracle 11g的Linux版本在修改了MEMORY\_TARGET或者SGA\_TARGET后启动可能会报错：

SQL> shutdown immediate  
Database closed.  
Database dismounted.  
ORACLE instance shut down.  
SQL> startup  
ORA-00845: MEMORY_TARGET not supported on this system

这个问题是由于设置SGA的大小超过了操作系统/dev/shm的大小：

解决这个问题只有两个方法，一种是修改初始化参数，使得初始化参数中SGA的设置小于/dev/shm的大小，另一种方法就是调整/dev/shm的大小。

[root@localhost db_1]# df -h /dev/shm //查看/dev/shm大小

Filesystem        Size         Used           Avail          Use%       Mounted  on  
tmpfs                   1.0G       260M         1.8G            13%         /dev/shm

&nbsp;

<pre class="lang:default decode:true">[root@localhost db_1]# vi /etc/fstab      //更换/dev/shm默认大小为2G
# /etc/fstab
# Created by anaconda on Tue Nov 13 00:29:16 2012
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=607ef5d8-042d-486f-a9a1-e0c8fa434c62 /                       ext4    defaults        1 1
UUID=27992806-1d47-41d8-be71-4300b5756dde /boot                   ext4    defaults        1 2
UUID=b4d786a5-c4f4-4827-a16c-451e750d1e64 /data                   ext4    defaults        1 2
UUID=0a3be703-d30a-493a-b7cf-db998124b6bc /home                   ext4    defaults        1 2
UUID=2e71dc8c-237c-49e4-960d-050e3f93c00c /opt                    ext4    defaults        1 2
UUID=ffedd612-bdc0-4c4f-a811-2703c87ee817 /tmp                    ext4    defaults        1 2
UUID=40b8c5d5-7356-4fc2-bdb5-332790177c1d /usr                    ext4    defaults        1 2
UUID=b0bd2554-59dc-4359-8f30-2e8b1ade11e1 /usr/local              ext4    defaults        1 2
UUID=28335a28-7724-4708-87d6-f9ba1573bca1 /var                    ext4    defaults        1 2
UUID=9d0fa977-91c7-4ce2-926f-fefba2cf7f4f swap                    swap    defaults        0 0
tmpfs                   /dev/shm     tmpfs   defaults,size=2048M  0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0

//注：本行defaults,size=10240M 中间无空格</pre>

[root@localhost db_1]#umount /dev/shm

[root@localhost db_1]#mount /dev/shm

查看tmpfs 大小

<pre class="lang:default decode:true">[root@localhost db_1]# df -lh
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda2             9.9G  418M  9.0G   5% /
tmpfs                 2.0G  260M  1.8G  13% /dev/shm
/dev/sda1             146M   28M  111M  20% /boot
/dev/sda11             36G  5.8G   28G  18% /data
/dev/sda8             5.0G  4.7G   37M 100% /home
/dev/sda3             9.9G  152M  9.2G   2% /opt
/dev/sda9             5.0G  531M  4.2G  12% /tmp
/dev/sda5             9.9G  2.2G  7.2G  24% /usr
/dev/sda6             9.9G  151M  9.2G   2% /usr/local
/dev/sda7             9.9G  328M  9.1G   4% /var
tmpfs                 2.0G  260M  1.8G  13% /dev/shm</pre>

修改/etc/fstab，重新mount /dev/shm，然后就可以启动数据库了。

[oracle@localhost db_1]$ su &#8211; oracle

[oracle@localhost db_1]$ sqlplus / as sysdba

SQL*Plus: Release 11.2.0.1.0 Production on Wed Nov 14 06:11:15 2012

Copyright (c) 1982, 2009, Oracle.  All rights reserved.

Connected to:

Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 &#8211; 64bit Production

With the Partitioning, OLAP, Data Mining and Real Application Testing options

SQL>startup

ORACLE instance started.

Total System Global Area 4743446528 bytes

Fixed Size 2143824 bytes

Variable Size 3892316592 bytes

Database Buffers 805306368 bytes

Redo Buffers 43679744 bytes

Database mounted.

Database opened

&nbsp;

&nbsp;
