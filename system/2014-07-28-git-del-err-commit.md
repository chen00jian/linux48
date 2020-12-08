---
title: git删除错误提交的commit
date: 2014-07-28
tags:
- git
categories:
 - System
---



有时候`push`了错误的信息，为了防止`patch`的时候错误的`log`，所以需要清除错误的`commit`


    git log --oneline  #查看提交历史commit

    git reset --hard <commit_id>  ##彻底回退到某个版本，本地的源码也会变为上一个版本的内容

    git push origin HEAD --force  ##强制push

