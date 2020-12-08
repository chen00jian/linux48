---
title: Google Chrome 安装包双击无任何反应
date: 2019-09-30
tags:
- Google
- Chrome
categories:
 - System
---

今天升级最新版的**Google Chrome**，还没等升级完成就报错了，然后chrome就打不开，于是清理注册表，删除文件夹，重启windows，继续重装


于是，就发生了，无论我怎么双击**Google Chrome**安装包都没任何反应...


上网搜了，有不少人遇到这个问题，而最优的解决方案是：先卸载旧版的...可是旧版的卸载程序已经被我暴力删除了(#‵′)凸


搜了很久没找到解决方法，于是自己动手解决一下：

先用Everything搜索C盘，把google相关的文件夹删掉（什么，你不知道什么是Everything？自己百度去）。

**把注册表`HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Google`删除**，可以试试删除注册表的其他google项（不过我没删貌似也没什么问题）。



然后就可以了，双击安装吧。

参考

https://blog.csdn.net/weixin_34050427/article/details/92791426
