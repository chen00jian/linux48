---
title: git安装使用
date: 2013-07-07
tags:
- git
categories:
 - System
---


1.安装

```bash
sudo apt-get install git  
sudo apt-get install git-core
```

2.创建密钥加入github

```bash
ssh-keygen  
cat .ssh/id_rsa.pub
```

进入这个页面https://github.com/settings/ssh把密钥复制到github

3.验证

```bash
pi@raspberrypi:~$ ssh git@github.com  
PTY allocation request failed on channel 0  
Hi koy1619! You&#8217;ve successfully authenticated, but GitHub does not provide shell access.  
Connection to github.com closed.  
pi@raspberrypi:~$
```

出现此提示即可使用github

4.github常用简单命令

```bash
git clone https://github.com/hugcoday/hugcoday.github.com.git koy1619.github.com #从github检出项目仓库
git init  #初始化仓库
git add -A  #添加新文件或者更改新文件
git commit -m "add new blog" . #提交文件到本地
git remote set-url origin git@github.com:koy1619/koy1619.github.com.git #查看repository上的所有分支
git push -u origin master #push到服务器上
```

```bash
git源码编译安装

yum install perl-ExtUtils-Embed zlib  zlib-devel -y
yum install openssl-devel curl-devel expat-devel gettext-devel zlib-devel
yum install gcc

tar zxvf v2.12.0.tar.gz
cd git-2.12.0/
make prefix=/usr/local/git
make prefix=/usr/local/git install
vim /etc/profile
export PATH=/usr/local/git/bin
source  /etc/profile
git --version
```


更多请访问 http://git.gitcafe.com/book/zh
