---
title: wordpress后台主题只有一个解决方法
date: 2014-04-05
tags:
- wordpress
- php
categories:
 - System
---




更换服务器重新搭建了环境之后发现wordpress后台主题只有一个，后来才了解到，原来是scandir函数被禁止掉了，所以在php.ini查找下这个函数，会发现如下：

```bash
disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,
proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,
```

则只需将scandir删掉，并重启服务即可！