---
title: SVN强制提交commit
date: 2014-11-12
tags:
- svn
categories:
 - System
---



不少开发员提交修改的时候都不写注释，导致查看历史时很费劲，也不太符合规范。这时候就需要强制开发人员提交的时候填上注释，否则无法提交！
 
利用svn的pre-commit钩子可简单实现此要求。
 
进入仓库project1/hooks目录，找到pre-commit.tmpl文件，重命名，去掉后缀.tmpl


```bash
[root@test yunwei]# cat hooks/pre-commit
#!/bin/sh


REPOS="$1"
TXN="$2"

SVNLOOK=/usr/bin/svnlook

LOGMSG=`$SVNLOOK log -t "$TXN" "$REPOS" | grep "[a-zA-Z0-9]" | wc -c` 
if [ "$LOGMSG" -lt 8 ];
then 
   echo -e "nLog message cann't be empty! you must input more than 8 chars as comment!." 1>&2 
   exit 1 
fi 

exit 0
[root@test yunwei]#
```