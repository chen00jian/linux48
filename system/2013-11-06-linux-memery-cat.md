---
title: linux查看内存相关命令
date: 2013-11-06
tags:
- 内存
- memory
categories:
 - System
---


Linux 查看内存的插槽数，已经使用多少插槽。每条内存多大，已使用内存多大<!-- more -->

```bash
[root@mysql1 ~]# dmidecode|grep -P -A5 "Memory\s+Device"|grep Size|grep -v Range
Size: 4096 MB
Size: 4096 MB
Size: No Module Installed
Size: No Module Installed
Size: No Module Installed
Size: No Module Installed
Size: 4096 MB
Size: 4096 MB
Size: No Module Installed
Size: No Module Installed
Size: No Module Installed
Size: No Module Installed
```

查看内存支持的最大内存容量

```
[root@mysql1 ~]# dmidecode|grep -P 'Maximum\s+Capacity'
Maximum Capacity: 192 GB
```

查看内存的频率

```bash
[root@mysql1 ~]# dmidecode|grep -A16 "Memory Device"|grep 'Speed'
Speed: 1333 MHz
Speed: 1333 MHz
Speed: Unknown
Speed: Unknown
Speed: Unknown
Speed: Unknown
Speed: 1333 MHz
Speed: 1333 MHz
Speed: Unknown
Speed: Unknown
Speed: Unknown
Speed: Unknown
```

查看内存详情

```bash
dmidecode|grep -A16 "Memory Device"
```