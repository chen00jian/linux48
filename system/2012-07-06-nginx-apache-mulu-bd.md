---
title: Nginx、Apache目录浏览功能
date: 2012-07-06
tags:
- nginx
- apache
categories:
 - System
---



1，Apache http.conf的虚拟主机默认配置下已经开启了这个功能。

```bash
Options Indexes FollowSymLinks
AllowOverride None
Order allow,deny
Allow from all
```

如果想关闭，有两种方式：
1）将Indexes去掉
Options FollowSymLinks
2）在Indexes前加上“-”（+ 代表允许目录浏览；–代表禁止目录浏览） Options -Indexes FollowSymLinks

2，Nginx默认不允许列出整个目录，开启功能只需要在nginx.conf的server或http段中添加以下配置即可。

```bash
autoindex on; #开启功能  
autoindex_exact_size off; #off显示出文件的大概大小，单位是kB、MB、GB；on显示bytes  
autoindex_localtime on; #off显示的文件时间为GMT时间；on显示为文件的服务器时间
```


TIP注意网站根目录下不要出现index，不然会显示index的内容！当然也可在conf自行修改！
