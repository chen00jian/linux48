---
title: Redis-stat的安装与使用
date: 2016-09-15
tags:
- redis
categories:
 - Database
---

:::tip 
redis-stat是一个用ruby写成的监控redis的程序，基于info命令获取信息，而不是通过monitor获取信息。
:::

<!-- more -->


## 安装ruby

```bash
yum install openssl* openssl-devel zlib-devel gcc gcc-c++ make autoconf readline-devel curl-devel expat-devel gettext-devel -y
wget http://ftp.ruby-lang.org/pub/ruby/2.4/ruby-2.4.0-preview1.tar.gz
tar zxvf ruby-2.4.0-preview1.tar.gz 
cd ruby-2.4.0-preview1
./configure --enable-shared --enable-pthread --prefix=/usr/local/ruby
make
make install
echo "PATH=$PATH:/usr/local/ruby/bin;export PATH" >> /etc/profile
source /etc/profile
gem sources --add https://ruby.taobao.org/ --remove http://rubygems.org/
gem sources -l 
```

## 安装redis-stat

```bash
git clone https://github.com/junegunn/redis-stat.git
cd redis-stat
gem install redis-stat 
cd bin
redis-stat --verbose --server=3000 127.0.0.1:6379 127.0.0.1:16379 127.0.0.1:26379
redis-stat --verbose --server=3000 127.0.0.1:6379 127.0.0.1:16379 127.0.0.1:26379
redis-stat --verbose --server=3000 127.0.0.1:6379 127.0.0.1:16379 127.0.0.1:26379  1     #每隔1S  不停的跑
redis-stat --verbose --server=3000 127.0.0.1:6379 127.0.0.1:16379 127.0.0.1:26379  1 8   #每隔1S  总共跑8次
```
