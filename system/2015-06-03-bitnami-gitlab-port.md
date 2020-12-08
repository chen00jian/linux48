---
title: bitnami版gitlab修改端口
date: 2015-06-03
tags:
- gitlab
- bitnami
categories:
 - System
---




bitnami版gitlab默认安装好web端口为80

为了便于开放到外部访问，需要把端口改为其他的，比如8080


## 修改apache主配置文件


	[root@iZ23m1d4vwiZ ~]# vim /opt/gitlab-6.8.1-0/apache2/conf/httpd.conf

	Listen 8080

## 修改apache的bitnami的配置文件

	[root@iZ23m1d4vwiZ ~]# vim /opt/gitlab-6.8.1-0/apache2/conf/bitnami/bitnami.conf
	# Default Virtual Host configuration.
	
	<IfVersion < 2.3 >
	  NameVirtualHost *:8080
	  NameVirtualHost *:443
	</IfVersion>
	
	<VirtualHost _default_:8080>
	  DocumentRoot "/opt/gitlab-6.8.1-0/apache2/htdocs"
	  <Directory "/opt/gitlab-6.8.1-0/apache2/htdocs">
	    Options Indexes FollowSymLinks
	    AllowOverride All
	    <IfVersion < 2.3 >
	      Order allow,deny
	      Allow from all
	    </IfVersion>
	    <IfVersion >= 2.3 >
	      Require all granted
	    </IfVersion>
	  </Directory>

## 修改gitlab-shell的配置文件

	[root@iZ23m1d4vwiZ ~]# vim /opt/gitlab-6.8.1-0/apps/gitlab/gitlab-shell/config.yml
	# GitLab user. git by default
	user: git

	# Url to gitlab instance. Used for api calls. Should end with a slash.
	gitlab_url: "http://120.26.103.123:8080/"

## 修改gitlab的apache主目录配置文件

	[root@iZ23m1d4vwiZ ~]# vim /opt/gitlab-6.8.1-0/apps/gitlab/htdocs/config/gitlab.yml
	# # # # # # # # # # # # # # # # # #
	# GitLab application config file  #
	# # # # # # # # # # # # # # # # # #
	#
	# How to use:
	# 1. copy file as gitlab.yml
	# 2. Replace gitlab -> host with your domain
	# 3. Replace gitlab -> email_from
	
	production: &base
	  #
	  # 1. GitLab app settings
	  # ==========================
	
	  ## GitLab settings
	  gitlab:
	    ## Web server settings (note: host is the FQDN, do not include http://)
	    host: 120.26.103.123
	    port: 8080
	    https: false

## 修改gitlab的gitlabci-runner配置文件

	vim /opt/gitlab-6.8.1-0/apps/gitlabci/gitlabci-runner/config.yml

	url: http://120.26.103.123:80/gitlabci/
  

## 重启服务

	[root@iZ23m1d4vwiZ ~]# sh /opt/gitlab-6.8.1-0/ctlscript.sh  restart
