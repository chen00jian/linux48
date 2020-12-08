---
title: 利用SVNListParentPath增加http浏览仓库根目录的功能
date: 2014-12-17
tags:
- svn
categories:
 - System
---



使用SVNParentPath的时候，直接访问根目录的时候，总是得到以下错误提示：

```bash
403 Forbidden

Forbidden
You don't have permission to access / on this server.
```

下面的办法可以搞定它：

一、首先，Subversion1.3及以后版本支持SVNListParentPath ON，之前的版本只能使用PHP自己做。

二、Location 设置中最后要加上**/**，应该是`<Location /svn/>`而不是`<Location /svn>`否则可能不能访问。

三、通过“http://localhost/svn/” 来访问仓库列表，如果想让“http://localhost/svn”也起作用的话，需要在</Location>的后面增加重定向的设置：RedirectMatch ^(/svn)$ $1/  ，当然也可以采用RewriteEngine之类的办法。

四、修改后的httpd.conf的对应部分如下：

```bash
       <Location /svn/>
                   DAV svn
                   SVNListParentPath on
                   SVNParentPath /code/svndata
                   AuthType Basic
                   AuthName "Subversion repository"
                   AuthUserFile /code/svndata/passwd
                   AuthzSVNAccessFile /code/svndata/authz
                   Require valid-user
       </Location>
```

**TIP: SVNPath 与 SVNParentPath区别**

dav_svn.conf 的配置中有 SVNPath 与 SVNParentPath 两个选项.
SVNPath用于只有一个项目的情况,此时如果在主目录下面再建新项目,则不能访问.提示没有权限.
如果有多个项目的话，此时应该使用SVNParentPath来设置父目录来设置项目的父目录,这样子目录里面可以有多个项目了。然后auth文件里面可以定义子目录的权限，apache的/etc/httpd/conf.d/subversion.conf 配置文件里面设置一个location就可以了。

```bash
<Location /svn>
DAV svn
SVNParentPath /tmp/svntest/
AuthType Basic
AuthName "Subversion"
AuthUserFile /tmp/svntest/passwd
AuthzSVNAccessFile /tmp/svntest/authz
Require valid-user
</Location>
```

以后多个子项目都是用同样的认证文件，访问方式就为 http://ip/svn/pro1    http://ip/svn/pro2

```bash
[root@svn svntest]# ls
authz  passwd  pro1  pro2
[root@svn svntest]# pwd
/tmp/svntest
```

认证文件给子项目赋权。

```bash
[root@svn svntest]# cat authz 
[pro1:/]
user1 = rw
[pro2:/]
user1 = rw
```

参考
http://blog.csdn.net/islq/article/details/666911
http://54im.com/svn/svnpath-svnparentpath.html


