---
title: 误卸载python导致yum无法使用修复事件
date: 2012-07-08
tags:
- python
- yum
categories:
 - System
---




由于服务器需要升级python，参照了一篇坑爹的文章卸载了旧版python 
卸载旧的python

```bash
sudo rpm -evf --nodeps python
```

导致yum无法使用 

```bash
# yum -v
There was a problem importing one of the Python modules
required to run yum. The error leading to this problem was:
No module named yum<br />
Please install a package which provides this module, or
verify that the module is installed correctly.
It's possible that the above module doesn't match the
current version of Python, which is:
2.4.3 (#1, Sep  3 2009, 15:37:12)
    [GCC 4.1.2 20080704 (Red Hat 4.1.2-46)]
    If you cannot solve this problem yourself, please go to
    the yum faq at:http://wiki.linux.duke.edu/YumFaq`
```

由于yum是基于python  
centos6.2默认使用python2.6.6，我又源码安装了一遍python2.6.6，  
修改了vi /usr/bin/yum  

```bash
#/usr/bin/python修改为#/usr/bin/python2.4
```


执行yum-v还是不行~~

于是就从centos6.2光盘找python和yum的rpm包安装，一番尝试之后，发现有N个package需要重新安装，这里就不写尝试过程，终于搞定！

解决方法如下

cnetos6.2*64光盘rpm包地址http://mirrors.ustc.edu.cn/centos/6.2/os/x86_64/Packages/

需要安装这几个包  

```bash
python-2.6.6-29.el6.x86_64.rpm
python-devel-2.6.6-29.el6.x86_64.rpm
python-iniparse-0.3.1-2.1.el6.noarch.rpm
python-setuptools-0.6.10-3.el6.noarch.rpm
python-urlgrabber-3.9.1-8.el6.noarch.rpm
rpm-python-4.8.0-19.el6.x86_64.rpm
yum-3.2.29-22.el6.centos.noarch.rpm
yum-metadata-parser-1.1.2-16.el6.x86_64.rpm
python-pycurl-7.19.0-8.el6.x86_64.rpm
```

注意rpm命令，必须要追加 –replacepkgs 参数，强制其重新安装，否则rpm会报告说package已安装。 

```bash
rpm -Uvh –replacepkgs ***.rpm
```

如果仍然无法运行Yum，则运行 Python，import yum，查询下缺少什么东西。

```bash
# python
Python 2.6.6 (r266:84292, Dec 7 2011, 20:48:22)
[GCC 4.4.6 20110731 (Red Hat 4.4.6-3)] on linux2
Type “help”, “copyright”, “credits” or “license” for more information. 
>>> import yum
```

如果仍有packag 缺失，import yum，会提示相关的错误，查找对应的rpm，装上即可，重复此过程，直到 yum 正常。
