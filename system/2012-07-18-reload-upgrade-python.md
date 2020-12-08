---
title: Centos平滑升级python事件
date: 2012-07-18
tags:
- centos
- python
categories:
 - System
---



误卸载python导致yum无法使用,所以要升级python不能卸载之前的版本，由于源码安装的python都是平滑安装的，它不会覆盖原python目录而是新建目录安装的

所以需要升级python版本的源码安装就是了

1.源码安装

```bash
tar jxvf  Python2.7.2.tar.bz2
cd Python2.7.2
./configure
#./configure --prefix=/usr/local/python2.7.2 --with-ssl --enable-optimizations
make	
make install
```

2.查看Python版本：  

```bash
/usr/local/bin/python2.7 -V
```

3.建立软连接，使系统默认的python指向python2.7  
正常情况下即使python2.7安装成功后，系统默认指向的python仍然是2.6.6版本，考虑到yum是基于python2.6.6才能正常工作  
所以需要将系统默认的python指向到2.6版本  

```bash
mv /usr/bin/python  /usr/bin/python.bak
ln -s //usr/local/bin/python2.7 /usr/bin/python
```

4.检验python指向是否成功  

```bash
python -V
```

5.解决系统python软链接指向python2.7版本后，yum不能正常工作 

```bash
vi /usr/bin/yum
```
将文本编辑显示的#/usr/bin/python修改为#/usr/bin/python2.6，保存修改
