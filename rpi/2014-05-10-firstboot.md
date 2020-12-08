---
title: 关于firstboot
date: 2014-05-10
tags:
- RaspberryPi
categories:
 - RaspberryPi
---



由于今天安装Pidora 的时候执行初始化firstboot意外关闭，导致不能再次执行，查了一下资料

一般安装完linux后，redhat会提供一个名为firstboot的服务，它负责协助配置redhat一些重要的信息

但是，firstboot服务只会在安装完后第一次开机执行，如果是升级或者第二次以后都不会启动这个服务

所以就导致了一些如果配置错误或者不恰当的话没法重新配置

所以在这里分享个小技巧：

    vim /etc/sysconfig/firstboot
    

其内容为：RUN_FIRSTBOOT=NO，将其no修改为yes

重启之后执行

    python /usr/sbin/firstboot
    

即可运行初始化步骤，配置完毕之后可将其RUN_FIRSTBOOT在改回no即可。

