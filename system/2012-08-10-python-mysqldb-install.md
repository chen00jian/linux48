---
title: CentOS下python-mysqldb安装事件
date: 2012-08-10
tags:
- python
categories:
 - System
---



未安装python-mysqldb的时候导入MySQLdb报错

```bash
# python

Python 2.7.2 (default, Jul 13 2012, 18:30:00)  
[GCC 4.4.6 20120305 (Red Hat 4.4.6-4)] on linux2  
Type help, copyright credits or license for more information.  
>>> import MySQLdb  
Traceback (most recent call last):  
File <stdin>, line 1, in <module>  
ImportError: No module named MySQLdb  
>>>
```

下载安装MySQL-python

```bash
wget http://pypi.python.org/packages/source/M/MySQL-python/MySQL-python-1.2.3.tar.gz#md5=215eddb6d853f6f4be5b4afc4154292f  
tar zxvf MySQL-python-1.2.3.tar.gz  
cd MySQL-python-1.2.3  
python setup.py build  
Traceback (most recent call last):  
File setup.py, line 5, in <module>  
from setuptools import setup, Extension  
ImportError: No module named setuptools
```

安装报错，还需下载安装setuptools

```bash
get http://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11-py2.7.egg#md5=fe1f997bc722265116870bc7919059ea
sh setuptools-0.6c11-py2.7.egg  
```

python导入setuptools成功

```bash
python  
Python 2.7.2 (default, Jul 13 2012, 18:30:00)  
[GCC 4.4.6 20120305 (Red Hat 4.4.6-4)] on linux2  
Type help copyright credits or license for more information.  
>>> import setuptools
```

继续编译安装MySQL-python

```bash
python setup.py build 
python setup.py install
```

python导入MySQLdb成功

```bash 
>>> import MySQLdb  
/usr/local/lib/python2.7/site-packages/MySQL\_python-1.2.3-py2.7-linux-x86\_64.egg/\_mysql.py:3: UserWarning: Module \_mysql was already imported from /usr/local/lib/python2.7/site-packages/MySQL\_python-1.2.3-py2.7-linux-x86\_64.egg/_mysql.pyc, but /home/setup/MySQL-python-1.2.3 is being added to sys.path  
>>> import MySQLdb  
>>>
```