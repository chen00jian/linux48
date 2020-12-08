---
title: sqlite3源码升级事件
date: 2012-08-03
tags:
- sqlite3
categories:
 - System
---



由于centos6.2自带了SQLite version 3.6.20，有必要的时候升级一下！

从其官方网站（<http://www.sqlite.org/download.html>）下载源码sqlite-3.7.0.tar.gz或更高版本

```bash
tar zxvf sqlite-3.7.0.tar.gz
cd sqlite-3.7.0.tar.gz
./configure &#8211;prefix=/usr/local/sqlite
make
make install
```

安装好SQLite后，主要包括命令文件、头文件和库文件。


使用时将sqlite3命令文件和库文件路径导入到环境变量，可修改~/.bashrc文件或~/.bash_profile文件或/etc/profile文件。

```bash
$ vi ~/.bashrc
export PATH=/usr/local/sqlite/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/sqlite/lib:$LD_LIBRARY_PATH
$ source ~/.bashrc
```