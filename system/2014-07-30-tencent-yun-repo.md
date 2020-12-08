---
title: 腾讯云的YUM repo
date: 2014-07-30
tags:
- yum
categories:
 - System
---



用了半年多的腾讯云和ucloud，发现他们都是和阿里云一样自建的软件源

    http://centos.mirrors.cs.ucloud.cn/centos
    http://mirrors.tencentyun.com/centos

特别是软件包非常全，而且也很稳定。

以前要`yum`安装`nginx` `php-fpm`等等还要下载源码编译，或者添加`安装epel yum源`

    rpm -ivh  http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

用过的都知道，此源位于国外，国内访问很慢。那我们大可以把yum源换成腾讯或者是ucloud的地址即可！

但你有没发觉上面的地址不能访问呢？是的，我们发现这域名指向了腾讯云的内网。

没关系，在腾讯云内通过nginx使用反向代理建立一个mirrors吧，nginx配置信息如下，其中mirrors.linux48.com改成你自己的服务器地址。

```bash
[root@VM_190_46_centos /etc/nginx/conf.d]# vim mirrors.linux48.com.conf 
server {
    listen 80;
    server_name mirrors.linux48.com;

    location / {
    proxy_pass    http://mirrors.tencentyun.com;
    proxy_redirect default;
        }
}
```

`service nginx restart` 即可访问 http://mirrors.linux48.com/ 是不是很赞呢！

附腾讯云的`epel.repo`和`centos.repo`

```bash
[root@tx-dispatch ~]# vim /etc/yum.repos.d/epel.repo 
[epel]
name=Extra Packages for Enterprise Linux 6 - $basearch
baseurl=http://mirrors.tencentyun.com/centos/epel/$basearch/
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
~                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                        
[root@VM_190_46_centos ~]# vim /etc/yum.repos.d/centos.repo 
[os]
name=Extra Packages for tlinux(Qcloud) - $basearch
baseurl=http://mirrors.tencentyun.com/centos/ustc/$releasever/os/$basearch/
enabled=1
gpgcheck=0

[updates]
name=Extra Packages for tlinux(Qcloud) - $basearch
baseurl=http://mirrors.tencentyun.com/centos/ustc/$releasever/updates/$basearch/
enabled=1
gpgcheck=0

[centosplus]
name=Extra Packages for tlinux(Qcloud) - $basearch
baseurl=http://mirrors.tencentyun.com/centos/ustc/$releasever/centosplus/$basearch/
enabled=1
gpgcheck=0

[contrib]
name=Extra Packages for tlinux(Qcloud) - $basearch
baseurl=http://mirrors.tencentyun.com/centos/ustc/$releasever/contrib/$basearch/
enabled=1
gpgcheck=0

[cr]
name=Extra Packages for tlinux(Qcloud) - $basearch
baseurl=http://mirrors.tencentyun.com/centos/ustc/$releasever/cr/$basearch/
enabled=1
gpgcheck=0

[extras]
name=Extra Packages for tlinux(Qcloud) - $basearch
baseurl=http://mirrors.tencentyun.com/centos/ustc/$releasever/extras/$basearch/
enabled=1
gpgcheck=0

[fasttrack]
name=Extra Packages for tlinux(Qcloud) - $basearch
baseurl=http://mirrors.tencentyun.com/centos/ustc/$releasever/fasttrack/$basearch/
enabled=1
gpgcheck=0

~                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                           
[root@VM_190_46_centos ~]# 
```





