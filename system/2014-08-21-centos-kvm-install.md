---
title: Redhat/CentOS系统KVM虚拟机安装过程详解
date: 2014-08-21
tags:
- KVM
categories:
 - System
---

::: tip
KVM 是指基于 Linux 内核的虚拟机（Kernel-based Virtual Machine）。 2006 年 10 月，由以色列的Qumranet 组织开发的一种新的“虚拟机”实现方案。 2007 年 2 月发布的 Linux 2.6.20 内核第一次包含了 KVM 。增加 KVM 到 Linux 内核是 Linux 发展的一个重要里程碑，这也是第一个整合到 Linux 主线内核的虚拟化技术。
:::

<!-- more -->

# Redhat/CentOS系统KVM虚拟机安装过程详解


## 什么是 KVM ?

KVM 是指基于 Linux 内核的虚拟机（Kernel-based Virtual Machine）。 2006 年 10 月，由以色列的Qumranet 组织开发的一种新的“虚拟机”实现方案。 2007 年 2 月发布的 Linux 2.6.20 内核第一次包含了 KVM 。增加 KVM 到 Linux 内核是 Linux 发展的一个重要里程碑，这也是第一个整合到 Linux 主线内核的虚拟化技术。

KVM 在标准的 Linux 内核中增加了虚拟技术，从而我们可以通过优化的内核来使用虚拟技术。在 KVM 模型中，每一个虚拟机都是一个由 Linux 调度程序管理的标准进程，你可以在用户空间启动客户机操作系统。一个普通的 Linux 进程有两种运行模式：内核和用户。 KVM 增加了第三种模式：客户模式（有自己的内核和用户模式）。

一个典型的 KVM 安装包括以下部件：
> * 一个管理虚拟硬件的设备驱动，这个驱动通过一个字符设备 /dev/kvm 导出它的功能。通过 /dev/kvm每一个客户机拥有其自身的地址空间，这个地址空间与内核的地址空间相分离或与任何一个正运行着的客户机相分离。
> * 一个模拟硬件的用户空间部件，它是一个稍微改动过的 QEMU 进程。从客户机操作系统执行 I/O 会拥有QEMU 。 QEMU 是一个平台虚拟化方案，它允许整个 PC 环境（包括磁盘、显示卡（图形卡）、网络设备）的虚拟化。任何客户机操作系统所发出的 I/O 请求都被拦截，并被路由到用户模式用以被 QEMU 过程模拟仿真。


## CentOS上安装KVM功能模块步骤

**1.KVM 需要有 CPU 的支持（Intel VT 或 AMD SVM），在安装 KVM 之前检查一下 CPU 是否提供了虚拟技术的支持。**

> * 　　基于 Intel 处理器的系统，运行`grep vmx /proc/cpuinfo`查找 CPU flags 是否包括 vmx 关键词
> * 　　基于 AMD 处理器的系统，运行`grep svm /proc/cpuinfo`查找 CPU flags 是否包括 svm 关键词
> * 　　检查BIOS，确保BIOS里开启VT选项:

注 : 一些厂商禁止了机器 BIOS 中的 VT 选项 , 这种方式下 VT 不能被重新打开。**

注意：/proc/cpuinfo 仅从 Linux 2.6.15(Intel) 和 Linux 2.6.16(AMD) 开始显示虚拟化方面的信息。请使用 uname -r 命令查询您的内核版本。如有疑问，请联系硬件厂商。

**2.iptables设置**

```bash
[root@localhost qemu]# cat /bin/iptables.sh 
modprobe ip_conntrack_ftp
iptables -F
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o em1  -j ACCEPT
iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#for ping:
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

#for kvm
iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT

iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP
[root@localhost qemu]# 
```

**3.安装与启动**

    yum install kvm libvirt python-virtinst qemu-kvm virt-viewer bridge-utils

    /etc/init.d/libvirtd start


**4.建立虚拟机**

划分硬盘

    qemu-img create -f qcow2 -o preallocation=metadata /home/kvm/centos65-x64-mysql.qcow2 200G

安装KVM，下面是两种常见的网络连接方式，默认是default，适用于不同需求的网络环境，后面配置KVM中会详细说明。

bridge网络模式

    virt-install --name=gatewat-4 --ram 4096 --vcpus=4 -f /home/kvm/gateway-4.qcow2 --cdrom /home/iso/CentOS-6.5-x86_64-bin-DVD1.iso --graphics vnc,listen=0.0.0.0,port=5920, --network bridge=br0 --force --autostart

NAT网络模式

    virt-install --name=test --ram 512 --vcpus=1 -f /home/kvm/test.qcow2 --cdrom /opt/CentOS-6.5-x86_64-bin-DVD1.iso --graphics vnc,listen=0.0.0.0,port=5988, --network network=default, --force --autostart

**5.启动**

使用`virsh list --all`查看已安装的kvm

使用`virsh start test`启动虚拟机

使用VNC工具连接KVM来进行初始化配置

## 配置KVM

使用`virsh-install`安装完KVM之后，会自动生成相应配置

KVM的配置文件存储在`/etc/libvirt/qemu/`

```bash
[root@localhost ~]# cd /etc/libvirt/qemu/
[root@localhost qemu]# ll
total 24
drwxr-xr-x. 2 root root 4096 Jul 24 17:30 autostart
drwx------. 3 root root 4096 Jun 20 19:21 networks
-rw-------. 1 root root 2566 Aug 20 18:28 vm_1.xml
-rw-------. 1 root root 2560 Jul  4 02:02 vm_2.xml
-rw-------. 1 root root 2566 Aug 20 18:28 vm_3.xml
```

长的大概是这个样子

```bash
[root@localhost qemu]# cat vm_1.xml 
<!--
WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE 
OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
  virsh edit vm_1
or other application using the libvirt API.
-->

<domain type='kvm'>
  <name>vm_1</name>  //此处为hostname
  <uuid>2f952159-b231-80a4-8086-d49978513fb4</uuid>  //此处为uuid标识
  <memory unit='KiB'>8388608</memory>  //此处为内存
  <currentMemory unit='KiB'>8388608</currentMemory>
  <vcpu placement='static'>6</vcpu>  //此处为cpu核数
  <os>
    <type arch='x86_64' machine='rhel6.5.0'>hvm</type>
    <boot dev='hd'/>  //此处为启动项目，若想从光盘启动可设置为<boot dev='cdrom'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>  //此处为关机命令 使用 virsh destroy vm_1 关闭
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='file' device='disk'>  //此处为硬盘信息
      <driver name='qemu' type='raw' cache='none'/>
      <source file='/home/kvm/vm_1.qcow2'/>
      <target dev='hda' bus='ide'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <disk type='block' device='cdrom'>  //此处为cdrom信息，可修改为iso的路径
      <driver name='qemu' type='raw'/>
      <target dev='hdc' bus='ide'/>
      <readonly/>
      <address type='drive' controller='0' bus='1' target='0' unit='0'/>
    </disk>
    <controller type='usb' index='0'>  //此处为usb接口信息
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>
    <controller type='ide' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <interface type='network'>  //此处为网卡1信息，使用network也就是nat模式连接virbr0联网
      <mac address='52:54:00:9a:d7:82'/>
      <source network='default'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <interface type='bridge'>  //此处为网卡2信息，使用bridge桥接方式到br1
      <mac address='52:54:11:fd:39:23'/>
      <source bridge='br1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </interface>
//若要添加网卡可新加配置，注意修改mac地址
    <interface type='bridge'>
      <mac address='52:54:21:fd:39:23'/>
      <source bridge='br0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
    </interface>

    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='5920' autoport='no' listen='0.0.0.0'>  //此处为VNC连接端口
      <listen type='address' address='0.0.0.0'/>
    </graphics>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </memballoon>
  </devices>
</domain>
[root@localhost qemu]# 
```

后期可能会因为需求对KVM重新配置，这个时候我们只需要修改对应的`xml`文件即可

修改配置的时候需要关闭KVM `virsh destroy vm_1`

使用`virsh define vm_1.xml`使配置生效

使用`virsh start vm_1`启动虚拟机



## 配置网路环境

**1.nat模式配置**

KVM默认采用nat模式，用户网络（User Networking）：让虚拟机访问主机、互联网或本地网络上的资源的简单方法，但是不能从网络或其他的客户机访问客户机。在公网IP不够使用KVM还需要上网的时候可以使用，大大节省了公网IP！同时这种模式也使得KVM不用暴露在公网之中，也增加了安全性。

下图是虚拟机管理模块产生的接口关系：

![请输入图片描述][1]

其中virbr0是由宿主机虚拟机支持模块安装时产生的虚拟网络接口，也是一个switch和bridge，负责把内容分发到各虚拟机。

从图上可以看出，虚拟接口和物理接口之间没有连接关系，所以虚拟机只能在通过虚拟的网络访问外部世界，无法从网络上定位和访问虚拟主机。

下面是nat的default配置，可以自定义地址池

```bash
[root@localhost qemu]# cat /etc/libvirt/qemu/networks/default.xml 
<network>
  <name>default</name>
  <uuid>a8e0859c-4761-4d78-bcd6-eaeeceace429</uuid>
  <bridge name="virbr0" />
  <mac address='52:54:00:C9:D5:1E'/>
  <forward/>
  <ip address="192.168.122.1" netmask="255.255.255.0">
    <dhcp>
      <range start="192.168.122.2" end="192.168.122.254" />
    </dhcp>
  </ip>
</network>
[root@localhost qemu]# 
```

创建方法：

使用`virsh net-start default`来启动nat网络，同时，虚拟机支持模块会修改iptables规则，通过命令可以查看：

```bash
# iptables -t nat -L -nv
Chain PREROUTING (policy ACCEPT 16924 packets, 2759K bytes)
pkts bytes target     prot opt in     out     source               destination
Chain POSTROUTING (policy ACCEPT 2009 packets, 125K bytes)
pkts bytes target     prot opt in     out     source               destination        
 421 31847 MASQUERADE  all  --  *      *       192.168.122.0/24    !192.168.122.0/24   ----------->这条是关键，它配置了NAT功能。
Chain OUTPUT (policy ACCEPT 2011 packets, 125K bytes)
pkts bytes target     prot opt in     out     source               destination        
```

如果你由于不小心将IPTABLE清空或者STOP导致IPTABLE配置丢失，可以通过如下操作来恢复：

    virsh net-destroy default

    virsh net-start default


确认路由转发开启

    [root@localhost qemu]# more /proc/sys/net/ipv4/ip_forward 
    1


下面是一个KVM的nat模式的范例

```bash
[root@vm_1 data]# cat /etc/sysconfig/network-scripts/ifcfg-eth0

#使用dhcp
#DEVICE=eth0
#ONBOOT=yes
#TYPE=Ethernet
#BOOTPROTO=dhcp

#手动IP
DEVICE=eth0
ONBOOT=yes
IPADDR=192.168.122.3
NETMASK=255.255.255.0
GATEWAY=192.168.122.1
DNS1=192.168.122.1
TYPE=Ethernet
BOOTPROTO=static
IPV6INIT=no
USERCTL=no
[root@vm_web_1_1 data]# 
```


**2.Bridge方式**

虚拟网桥（Virtual Bridge）：设置好后客户机与互联网，客户机与主机之间都可以通信，试用于需要多个公网IP的环境。

Bridge方式即虚拟网桥的网络连接方式，是客户机和子网里面的机器能够互相通信。可以使虚拟机成为网络中具有独立IP的主机。

桥接网络（也叫物理设备共享）被用作把一个物理设备复制到一台虚拟机。网桥多用作高级设置，特别是主机多个网络接口的情况。

![请输入图片描述][2]


  [1]: ../images/zJHjranPQKmOy5L.png
  [2]: ../images/1ywpnNWzhEfZSXD.png

如上图，网桥的基本原理就是创建一个桥接接口br0，在物理网卡和虚拟网络接口之间传递数据。

创建方法：

不用过多命令，只需要修改好网卡的桥接方式，配好IP即可，下面是范例，不用注释仔细读一遍就能看懂了！


```bash
========kvm_server==========

[root@localhost network-scripts]# cat ifcfg-br0 
DEVICE=br0
BOOTPROTO=none
TYPE=Bridge
IPADDR=114.137.122.233
NETMASK=255.255.255.128
GATEWAY=114.137.102.139
DNS1=202.96.122.83
IPV6INIT=no
NM_CONTROLLED=yes
ONBOOT=yes
USERCTL=no

[root@localhost network-scripts]# cat ifcfg-br1
DEVICE=br1
BOOTPROTO=none
TYPE=Bridge
IPADDR=192.168.1.12
NETMASK=255.255.255.0
IPV6INIT=no
ONBOOT=yes
USERCTL=no

[root@localhost network-scripts]# cat ifcfg-em1 
DEVICE=em1
ONBOOT=yes
BOOTPROTO=none
BRIDGE=br0
TYPE=Ethernet
IPV6INIT=no
USERCTL=no

[root@localhost network-scripts]# cat ifcfg-em2
DEVICE=em2
ONBOOT=yes
BOOTPROTO=none
BRIDGE=br1
TYPE=Ethernet
IPV6INIT=no
USERCTL=no

========kvm==========

[root@gateway-2 network-scripts]# cat ifcfg-eth0
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
IPADDR=114.137.122.222
NETMASK=255.255.255.128
GATEWAY=114.137.102.139
DNS1=202.96.122.83

[root@gateway-2 network-scripts]# cat ifcfg-eth0:1
DEVICE=eth0:1
TYPE=Ethernet
ONBOOT=yes
IPADDR=114.137.122.123
NETMASK=255.255.255.128
NM_CONTROLLED=yes
BOOTPROTO=static

[root@gateway-2 network-scripts]# cat ifcfg-eth1
DEVICE=eth1
ONBOOT=yes
IPADDR=192.168.1.25
NETMASK=255.255.255.0
TYPE=Ethernet
BOOTPROTO=static
IPV6INIT=no
USERCTL=no
```

**注意：网络配置可以同时存在nat和Bridge，看最上面的vm_1.xml**





## ---2014.10.29更新---

由于按照上文的NAT方式配置的机器，过了几个月宿主机重启之后死活连接不上外网ping不通`virbr0`(192.168.122.1)，`virsh net-destroy default`和 `virsh net-start default`之后也是不行，尝试了各种方案，最后`/etc/init.d/libvirtd restart`之后会偶尔联上外网ping通192.168.122.1，但是`virsh net-destroy default`和 `virsh net-start default`之后又连不上外网，今天又在测试环境测试都是OK的也没发现问题~~~~

真实匪夷所思~~~

最后抱着尝试一下的心态按照http://www.linuxidc.com/Linux/2012-05/61445.htm这篇文章配置了，果断就OK了！再此记录一下！

**宿主机配置**

```bash
[root@web8 qemu]# cp /etc/libvirt/qemu/networks/default.xml /etc/libvirt/qemu/networks/default.xml.bk 

[root@web8 qemu]# cat /etc/libvirt/qemu/networks/default.xml

<network>
  <name>default</name>
  <uuid>ea07af3d-fd95-444d-a1d2-a0ae5fce43de</uuid>
  <forward mode='nat'/>   //此处增加mode参数为nat
  <bridge name='virbr0' stp='on' delay='0' />
  <mac address='52:54:00:89:DD:12'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254' />
    </dhcp>
  </ip>
</network>

[root@web8 qemu]# virsh net-define /etc/libvirt/qemu/networks/default.xml
[root@web8 qemu]# virsh net-destroy default
[root@web8 qemu]# virsh net-start default

[root@web8 qemu]# cat  vm.xml

······
    <interface type='network'>
      <mac address='52:54:00:66:6e:49'/>
      <source network='default'/>
      <model type='virtio'/>  //此处为新增参数mode
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
······

```
