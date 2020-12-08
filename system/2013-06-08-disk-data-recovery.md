---
title: 记录一次服务器数据恢复
date: 2013-06-08
tags:
- 服务器
- 数据恢复
categories:
 - System
---

# 记录一次服务器数据恢复

6月5号上海静安区大面积停电，导致所在机房一台老旧服务器宕机无法启动，去机房开机查看无法开机，为了不耽误时间果断去IDC拿回机器恢复数据！

以下为恢复思路和过程图，敬请各位观看



<img class="alignnone" alt="" src="http://ww4.sinaimg.cn/mw690/45d8cb2dgw1e5el2tei82j20p50iu0xp.jpg" width="690" height="516" />



服务器硬盘（2快为riad1+0）拆下来挂载到本机（本机器为windows7，安装虚拟机）


<img class="alignnone" alt="" src="http://ww3.sinaimg.cn/mw690/45d8cb2dgw1e5el2soeuij20p50iuaee.jpg" width="690" height="516" />


新建虚拟机不装任何系统，只挂载服务器的2块硬盘


<img class="alignnone" alt="" src="http://ww2.sinaimg.cn/mw690/45d8cb2dgw1e5el2pjiu3j20jj0g440n.jpg" width="690" height="569" />


成功启动系统，这下就可以随意操作咯


<img class="alignnone" alt="" src="http://ww3.sinaimg.cn/mw690/45d8cb2dgw1e5el2q2msnj20qu0h4td5.jpg" width="690" height="440" />


如果这样子，说明服务器硬盘和文件系统为ok的，可能是整列卡或者其他地方坏掉了。

如果是硬盘或者文件系统有问题，则把硬盘挂载到可以启动的linux虚拟机以便读出来！
