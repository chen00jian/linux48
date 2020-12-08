---
title: centos6.2下php支持oracle
date: 2013-01-04
tags:
- centos
- php
- oracle
categories:
 - System
---



centos下使PHP支持oracle 11g，需要先安装oracle 11g的client

下载地址 http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html

我机器是64位的，需要安装下面3个包

```bash
> oracle-instantclient11.2-basic-11.2.0.3.0-1.x86_64.rpm  
> oracle-instantclient11.2-devel-11.2.0.3.0-1.x86_64.rpm  
> oracle-instantclient11.2-sqlplus-11.2.0.3.0-1.x86_64.rpm
```

1.安装oracle客户端

```bash
yum -y install libaio
rpm -ivh oracle-instantclient-*.rpm
echo /usr/lib/oracle/11.2/client64/lib/ > /etc/ld.so.conf.d/oracle_client.conf
/sbin/ldconfig
```

网上有说因为安装的是oracle 11g，为了防止后面的OCI编译不过去，需要修改oracle的clinet为10g，有待验证，不过我还是这样做了

```bash
ln -s /usr/include/oracle/11.2 /usr/include/oracle/10.2.0.1
ln -s /usr/lib/oracle/11.2 /usr/lib/oracle/10.2.0.1
```

修改环境变量

```bash
vi /etc/profile
export ORACLE_HOME=/usr/lib/oracle/11.2/client64/
export ORACLE_BASE=/usr/lib/oracle/11.2
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export NLS_LANG="AMERICAN_AMERICA.AL32UTF8"


source /etc/profile
```

2.编译安装php的pdo_oci模块

```bash
cd /home/setup/php/php-5.4.0/ext/pdo_oci/
/usr/local/php/bin/phpize
./configure with-php-config=/usr/local/php/bin/php-config with-pdo-oci=instantclient,/usr,10.2.0.1
make && make install
```

添加php的pdo_oci扩展

```bash
vi /usr/local/php/etc/php.ini
extension=pdo_oci.so
```

3.编译安装php的oci8模块

```bash
cd /home/setup/php/php-5.4.0/ext/oci8/
/usr/local/php/bin/phpize
./configure with-php-config=/usr/local/php/bin/php-config with-oci8=instantclient,/usr/lib/oracle/11.2/client64/lib/
make && make install
```

添加php的oci8扩展

```bash
vi /usr/local/php/etc/php.ini
extension=oci8.so
```

4.重启web服务器和php，查看phpinfo可以看到php的pdo_oci模块和oci8模块