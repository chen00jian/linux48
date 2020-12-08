---
title: CentOS yum安装配置LAMP+tomcat
date: 2012-06-27
tags:
- centos
- yum
- LAMP
- nginx
- php
- tomcat
- mysql
categories:
 - System
---



yum安装LAMP+tomcat

##一、准备篇：

1.配置防火墙，开启80端口、8080端口、3306端口  

```bash
#vi /etc/sysconfig/iptables  
-A INPUT -m state &#8211;state NEW -m tcp -p tcp &#8211;dport 80 -j ACCEPT（允许apache的80端口通过防火墙）  
-A INPUT -m state &#8211;state NEW -m tcp -p tcp &#8211;dport 80 -j ACCEPT（允许tomcat的8080端口通过防火墙）  
-A INPUT -m state &#8211;state NEW -m tcp -p tcp &#8211;dport 3306 -j ACCEPT（允许mysql的3306端口通过防火墙 ）  
重启防火墙使配置生效  
#/etc/init.d/iptables restart  
#service iptables restart
```


2.检查是否已经安装apache，mysql，php，tomcat  

    #rpm -q httpd（mysql，php，tomcat）

若已安装则  

    #yum remove httpd（mysql，php，tomcat）

#二、安装篇：

1. 安装Apahce, PHP, MySQL以及php连接mysql库组件。  

    #yum -y install httpd php mysql mysql-server php-mysql  

yum会到指定的服务器(mirror:163.com服务器)下载对应的软件版本，并自动处理依赖关系，并进行安装。

2. 安装apache扩展 
 
    #yum -y install httpd-manual mod_ssl mod_perl mod_auth_mysql  

让apache更好的支持其他的软件。

3. 安装php的扩展  

    yum -y install php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-bcmath php-mhash libmcrypt  

apache本身并不支持php文件，要安装对应的php软件，然后进行http.conf配置；让apache能解析.php文件。  
说明：Apache 网站的默认文档的路径是 /var/www/html，在这个目录里新建一个php探针文件  

```bash
cd /var/www/html  
touch index.php  
vi index.php  
<?php  
phpinfo();  
?>
```

    service httpd start  

http://localhost/浏览会显示很多 PHP5 的安装信息

4. 安装MySQL的扩展，并设置mysql密码  

    yum -y install mysql-connector-odbc mysql-devel libdbi-dbd-mysql  

跟好的实现mysql的功能。  
为root账户设置密码

    #service mysqld start  
    #mysql_secure_installation  

根据提示输入Y，回车  
输入2次密码，回车  
最后出现：Thanks for using MySQL!  
MySql密码设置完成

5. 配置开机启动服务  

    #/sbin/chkconfig httpd on [设置apache服务器httpd服务开机启动]  
    #/sbin/service httpd start [启动httpd服务,与开机启动无关]  
    #/sbin/service mysqld start [启动mysqld服务,与开机启动无关]

6. 简单配置文件：  
apache的配置文件是/etc/httpd/conf下  
modules放在/usr/lib/httpd下  
php的配置文件在/etc/php.d/下 和/etc/php.ini  
php的modules放在/usr/lib/php/modules下

7. 安装Tomcat5  

    #yum -y install tomcat5 tomcat5-webapps tomcat5-admin-webapps  

安装Tomcat5安装包和对应的依赖关系包

8. 启动Tomcat5  

    #service tomcat5 start  
    #chkconfig tomcat5 on 

9. 在浏览器输入http://你的IP:8080/,可以看到Apache SoftWare Foundation页，  
看到一个猫头 tomcat5安装成功

10. Apache与Tomcat整合  
如果网站需同时整合Apache与Tomcat可以使用JK或者Proxy方式  
使用VI编辑proxy_ajp.conf文件  

    #vi /etc/httpd/conf.d/proxy_ajp.conf  

输入以下内容  

    ProxyPass /tomcat/ ajp://localhost:8009/  

存储文件后，重启Apache

    #service httpd restart

在浏览器输入http://你的IP/tomcat/,可以看到Apache SoftWare Foundation页  
As you may have guessed by now, this is the default Tomcat home page. It can be found on the local  
filesystem at:

$CATALINA_HOME/webapps/ROOT/index.jsp

这样就可以解析 .jsp文件。
