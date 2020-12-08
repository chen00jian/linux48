---
title: CentOS NFS的安装配置、启动及mount挂载方法
date: 2014-07-31
tags:
- NFS
- mount
categories:
 - System
---



# CentOS NFS的安装配置、启动及mount挂载方法


## 环境介绍：

> * 　　服务器：centos 192.168.1.225

> * 　　客户端：centos 192.168.1.226

## 安装：

centos 5 :

    yum -y install nfs-utils portmap

centos 6 :

    yum -y install nfs-utils rpcbind

## 服务器端配置：

### 创建共享目录：

    [root@centos2 /]# mkdir /usr/local/test  


### NFS文件配置：

```bash
[root@centos2 /]# vi /etc/exports 
#增加一行：
/usr/local/test/ 192.168.1.226(rw,no_root_squash,no_all_squash,sync)

使配置生效：
[root@centos2 /]# exportfs -r
```

注：配置文件说明：

> * /usr/local/test/ 为共享的目录，使用绝对路径。
> * 192.168.1.226(rw,no_root_squash,no_all_squash,sync) 为客户端的地址及权限，地址可以是一个网段，一个IP地址或者是一个域名，域名支持通配符，如：*.youxia.com，地址与权限中间没有空格，权限说明：
> * rw：read-write，可读写；
> * ro：read-only，只读；
> * sync：文件同时写入硬盘和内存；
> * async：文件暂存于内存，而不是直接写入内存；
> * no_root_squash：NFS客户端连接服务端时如果使用的是root的话，那么对服务端分享的目录来说，也拥有root权限。显然开启这项是不安全的。
> * root_squash：NFS客户端连接服务端时如果使用的是root的话，那么对服务端分享的目录来说，拥有匿名用户权限，通常他将使用nobody或nfsnobody身份；
> * all_squash：不论NFS客户端连接服务端时使用什么用户，对服务端分享的目录来说都是拥有匿名用户权限；
> * anonuid：匿名用户的UID值，通常是nobody或nfsnobody，可以在此处自行设定；
> * anongid：匿名用户的GID值。

## 启动:

centos6:


    [root@centos2 /]# service rpcbind start
    [root@centos2 /]# service nfs start

centos 5


    [root@centos2 /]# service portmap start
    [root@centos2 /]# service nfs start


## 客户端挂载：

### 创建需要挂载的目录：

    [root@localhost ~]# mkdir /usr/local/test

### 测试挂载：

```bash
[root@localhost ~]# service rpcbind start  ##centos5 service portmap start
[root@localhost ~]# showmount -e 192.168.1.225
Export list for 192.168.1.225:
/usr/local/test 192.168.1.226
```

如果显示：`rpc mount export: RPC: Unable to receive; errno = No route to host`则需要在服务端关闭防火墙（稍候会详细说）。

### 挂载：

```bash
[root@localhost ~]# mount -t nfs 192.168.1.225:/usr/local/test /usr/local/test

[root@localhost ~]# mount
/dev/mapper/VolGroup-lv_root on / type ext4 (rw)
proc on /proc type proc (rw)
sysfs on /sys type sysfs (rw)
devpts on /dev/pts type devpts (rw,gid=5,mode=620)
tmpfs on /dev/shm type tmpfs (rw)
/dev/sda1 on /boot type ext4 (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
nfsd on /proc/fs/nfsd type nfsd (rw)
192.168.1.225:/usr/local/test on /usr/local/test type nfs (rw,vers=4,addr=192.168.1.225,clientaddr=192.168.1.226)
```

如果信息如上显示则挂载成功！

### 测试：

客户端生成一个文件：

```bash
[root@centos2 /]# cd /usr/local/test/
[root@centos2 test]# echo "hello nfs test">>test
[root@centos2 test]# ll
total 4
-rw-r--r-- 1 root root 15 Apr  9 13:24 test
```

服务端检查：

```bash
[root@centos2 /]# cd /usr/local/test/
[root@centos2 test]# ll
total 4
-rw-r--r-- 1 root root 15 Apr  9 13:24 test
```

挂载成功！

## 解除挂载：

```bash
[root@localhost ~]# umount /usr/local/test

[root@localhost ~]# mount
/dev/mapper/VolGroup-lv_root on / type ext4 (rw)
proc on /proc type proc (rw)
sysfs on /sys type sysfs (rw)
devpts on /dev/pts type devpts (rw,gid=5,mode=620)
tmpfs on /dev/shm type tmpfs (rw)
/dev/sda1 on /boot type ext4 (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
nfsd on /proc/fs/nfsd type nfsd (rw)
```

如果遇到：`umount.nfs: /usr/local/test: device is busy`

可能用命令：

```bash
[root@localhost /]# fuser -m -v /usr/local/test

                     用户     进程号 权限   命令
/usr/local/test/:              root       2798 ..c.. bash
                     root       2996 ..c.. su
[root@localhost /]# kill -9 2798

[root@localhost /]# kill -9 2996

[root@localhost /]# umount /usr/local/test
```

## 服务器端防火墙设置（NFS 开启防墙配置）：

1、修改/etc/service,添加以下内容（端口号必须在1024以下,且未被占用）

```bash
 # Local services  
    mountd 1011/tcp #rpc.mountd  
    mountd 1011/udp #rpc.mountd  
    rquotad 1012/tcp #rpc.rquotad  
    rquotad 1012/udp #rpc.rquotad
```

2、重启Linux NFS服务

    service nfs restart

3、此时rpc相关端口已经被固定,可以为Linux NFS添加防火墙规则

```bash
#portmap  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p tcp --dport 111 -j ACCEPT  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p udp --dport 111 -j ACCEPT  
#nfsd  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p tcp --dport 2049 -j ACCEPT  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p udp --dport 2049 -j ACCEPT  
#mountd  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p tcp --dport 1011 -j ACCEPT  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p udp --dport 1011 -j ACCEPT  
#rquotad  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p tcp --dport 1012 -j ACCEPT  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p udp --dport 1012 -j ACCEPT  
#rpc.statd  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p tcp --dport 32768 -j ACCEPT  
/sbin/iptables -A INPUT -s 192.168.1.0/254 -p udp --dport 32768 -j ACCEPT
```

或者
```bash
-A INPUT -m state --state NEW -m tcp -p tcp --dport 111 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 2049 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 1011 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 1012 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 32768 -j ACCEPT
```

客户端在挂载的时候遇到的一个问题如下，可能是网络不太稳定，NFS默认是用UDP协议，换成TCP协议即可：

    mount -t nfs 192.168.1.225:/usr/local/test /usr/local/test  -o proto=tcp -o nolock
