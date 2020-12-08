---
title: centos下nginx的https配置
date: 2014-06-25
tags:
- nginx
- https
categories:
 - System
---




HTTPS（全称：Hyper Text Transfer Protocol over Secure Socket Layer），是以安全为目标的HTTP通道，简单讲是HTTP的安全版。即HTTP下加入SSL层，HTTPS的安全基础是SSL，因此加密的详细内容就需要SSL。

### 首先确保系统上安装了openssl和openssl-devel

    # yum install openssl
    # yum install openssl-devel
    

### nginx需要支持ssl模块

    # ./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module 
    

### 生成证书

进入/etc/pki/tls/certs目录使用openssl生成

    # cd /etc/pki/tls/certs/
    # make server.key  //生成私钥
    # openssl rsa -in server.key -out server.key  //除去密码以便询问时不需要密码
    # make server.csr  //生成证书颁发机构,用于颁发公钥
    # openssl x509 -in server.csr -req -signkey server.key -days 365 -out server.crt
    

注意：最后一步是颁发公钥，不过由于我们并不是去CA证书中心申请的公钥，所以在使用的时候，客户端浏览器会跳出未受信任的警告。如果你在生产环境下，请去CA申请[enter link description here][1]。

### 编辑nginx虚拟主机配置文件，添加ssl模块参数

    vim /usr/local/nginx/conf/vhosts/server.com.conf
    server { 
        listen       443;  监听端口为443 
        server_name  server.com; 
    
        ssl                  on;  //开启ssl 
        ssl_certificate      /etc/pki/tls/certs/server.crt;  //证书位置 
        ssl_certificate_key  /etc/pki/tls/certs/server.key;  //私钥位置 
        ssl_session_timeout  5m;    //session超时
        ssl_protocols  SSLv2 SSLv3 TLSv1;  //指定密码为openssl支持的格式 
        ssl_ciphers  HIGH:!aNULL:!MD5; //密码加密方式 
        ssl_prefer_server_ciphers   on; //依赖SSLv3和TLSv1协议的服务器密码将优先于客户端密码 
    
        location / { 
            root   /home/wwwroot;
            index  index.html index.htm; 
        } 
    }

 [1]: https://billing.centriohost.com/cart.php?a=add&pid=21
