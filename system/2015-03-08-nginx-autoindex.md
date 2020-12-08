---
title: Nginx开启目录浏览
date: 2015-03-08
tags:
- nginx
categories:
 - System
---


```bash
server {
    server_name test.com;

    index index.html index.htm index.php;
    root /home/wwwroot/test/;

    location ~ ^(.*)/$ {
       charset utf-8;
       autoindex on;
       autoindex_format html;
       autoindex_localtime on;
       autoindex_exact_size off;
       add_after_body /.html/autoindex.html;

       allow 10.255.0.202;
       allow 10.10.3.0/24;

       deny  all;
    }

# 让yaml文件在浏览器中显示文本text/plain
location ~ .*/.*\.yaml$ {
    add_header Content-Type text/plain;
}

}
```
