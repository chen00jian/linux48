---
title: 访问phpmyadmin错误
date: 2014-07-24
tags:
- phpmyadmin
categories:
 - System
---





安装最新版4.2.6phpmyadmin访问错误，输入帐号密码无反应

![][1]  
错误代码

    phpMyAdmin - Error
    
    Error during session start; please check your PHP and/or webserver log file and configure your PHP installation properly. Also ensure that cookies are enabled in your browser.
    

原因是由于/usr/local/php下无session保存会话的一个机制文件

解决办法;  
首先检查vim /etc/php.ini  
查看里面session.save_path = &#8220;/usr/local/php/tmp/&#8221;是否注释掉。如果注释把；去掉。开启。

![][2]

mkdir -p /usr/local/php/tmp/  
chmod -R 777 /usr/local/php/tmp/

重启httpd或者fpm，即可解决。

浏览器再次访问成功进去。

然后去创建的目录下查看生成的会话内容。

![][3]

 [1]: ../images/cxkJV9u6Y1OErAF.jpg
 [2]: ../images/cxNnvUMPXmhCK1B.jpg
 [3]: ../images/BkRN8qdEXh9DtJK.jpg
