---
title: centos6.2升级python后处理sqlite3库事件
date: 2012-08-01
tags:
- centos
- python
- sqlite3
categories:
 - System
---




前段时间服务器升级了python，现在又需要 Python Sqlite 3 支持库，由于centos6.2自带了SQLite version 3.6.20，所以此处就不赘述sqlite3的安装了，下文会提到升级sqlite3

下面说一下此事件的过程

由于centos.2 默认安装的python版本是2.6。之前服务器升级到python2.7.2之后，导入sqlite3报错：

```bash
# python
>>> import sqlite3  
Traceback (most recent call last):  
File <stdin>, line 1, in <module>  
File /usr/local/lib/python2.7/sqlite3/__init__.py, line 24, in <module>  
from dbapi2 import *  
File /usr/local/lib/python2.7/sqlite3/dbapi2.py, line 27, in <module>  
from _sqlite3 import *  
ImportError: No module named _sqlite3
```

解决办法：

centos 6.2 默认没有安装sqlite-devel，所以要先安装sqlite-devel，再编译升级python，才可以使用sqlite3库。

1、先安装sqlite-devel：

```bash
yum install -y sqlite-devel
```

2、之后编译安装python 2.7.2

```bash
tar vxf Python-2.7.2.tar
./configure
make && make install
```

3.如果已经升级python则上一步只是重新编译，如果需要升级请参考"Centos平滑升级python事件"

4.验证

```bash
# python  
Python 2.7.2 (default, Aug 1 2012, 14:37:32)  
[GCC 4.4.6 20120305 (Red Hat 4.4.6-4)] on linux2  
Type help, copyright,credits or license for more information.  
>>> import sqlite3  
```
