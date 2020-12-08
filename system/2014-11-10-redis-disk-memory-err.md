---
title: redis 写磁盘出错Cannot allocate memory
date: 2014-11-10
tags:
- redis
- memory
categories:
 - System
---


# redis 写磁盘出错Cannot allocate memory


查看 Redis 日志
发现系统在频繁报错：

    [1821] 10 Nov 09:59:04.086 # Can't save in background: fork: Cannot allocate memory
    [1821] 10 Nov 09:59:10.002 * 1 changes in 900 seconds. Saving...


在小内存的进程上做一个fork,不需要太多资源，但当这个进程的内存空间以Ｇ为单位时，fork就成为一件很恐怖的操作。何况在16G内存的主机上fork 14G内存的进程呢？肯定会报内存无法分配的。更可气的是，越是改动频繁的主机上fork也越频繁，fork操作本身的代价恐怕也不会比假死好多少。

找到原因之后，直接修改内核参数 **vm.overcommit_memory = 1**

Linux内核会根据参数**vm.overcommit_memory**参数的设置决定是否放行。

 如果 **vm.overcommit_memory = 1**，直接放行
**vm.overcommit_memory = 0**：则比较 此次请求分配的虚拟内存大小和系统当前空闲的物理内存加上swap，决定是否放行。
**vm.overcommit_memory = 2**：则会比较 进程所有已分配的虚拟内存加上此次请求分配的虚拟内存和系统当前的空闲物理内存加上swap，决定是否放行。
 
 
linux设置**vm.overcommit_memory** 方法
永久性修改内核参数

在``/etc/sysctl.conf``文件里面加入或者直接删除也可以，因为它缺省值就是0

    vm.overcommit_memory = 0

运行使之生效

    sysctl -p