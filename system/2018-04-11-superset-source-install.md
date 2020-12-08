---
title: superset源码编译安装.md
date: 2018-04-11
tags:
- superset
categories:
 - System
---


由于pip安装太过于缓慢，故采用源码编译安装


```bash

#安装python setuptools pip pysqlite sqlite3
yum install -y sqlite-devel
wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tar.xz
xz -d Python-2.7.9.tar.xz
tar vxf Python-2.7.9.tar
cd Python-2.7.9
./configure --prefix=/usr/local/python27 --with-zlib=/usr/include
make && make install
cd /usr/bin/
mv python python26
cp /usr/local/python27/bin/python /usr/bin/
vi /usr/bin/yum
export PATH=$PATH:/usr/local/python27/bin

wget https://pypi.python.org/packages/72/c2/c09362ab29338413ab687b47dab03bab4a792e2bbb727a1eb5e0a88e3b86/setuptools-39.0.1.zip#md5=75310b72ca0ab4e673bf7679f69d7a62 
unzip setuptools-39.0.1.zip
cd setuptools-39.0.1
python setup.py build
python setup.py install
python
>>> import setuptools

wget https://pypi.python.org/packages/source/p/pip/pip-7.1.2.tar.gz
tar zxvf pip-7.1.2.tar.gz
cd pip-7.1.2
python setup.py build
python setup.py install

pip install pysqlite
python
>>> import pysqlite2
>>> import sqlite3



#安装nodejs  yarn
curl --silent --location https://rpm.nodesource.com/setup_9.x | sudo bash -
yum -y install nodejs
yum -y install yarn



#下载安装superset
git clone https://github.com/apache/incubator-superset.git

#检查依赖库
cd incubator-superset/superset/assets/
yarn
yarn cache clean -f
yarn install -g

#编译安装依赖库
yarn run build

#安装superset
cd ../..
python setup.py install


#初始化superset

step1.设置用户名与密码
fabmanager create-admin --app superset

step2.初始化数据库
superset db upgrade

step3.导入样本案例
superset load_examples

step4.创建默认规则与权限
superset init

step5.启动服务
superset runserver

step6. http://192.168.5.158:8088
```

