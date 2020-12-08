---
title: rm Argument list too long的解决办法
date: 2014-11-12
tags:
- rm
categories:
 - System
---





当目录下文件太多时，用rm删除文件会报错：

    -bash: /bin/rm: Argument list too long

提示文件数目太多。

解决的办法是使用如下命令：

    ls | xargs -n 10 rm -fr ls

输出所有的文件名(用空格分割) xargs就是将ls的输出，每10个为一组(以空格为分隔符)，作为rm -rf的参数也就是说将所有文件名10个为一组，由rm -rf删除