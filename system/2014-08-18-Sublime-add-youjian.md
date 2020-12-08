---
title: 将sublime text添加到右键菜单中
date: 2014-08-18
tags:
- sublime
categories:
 - System
---



使用的是免安装便携版的Sublime Text，所以右键加入菜单这样的事情也就是能自己手动来设置了。

将下面的代码保存为*.reg的文件，然后导入到注册表中，这样就可以在右键的菜单中打开文件或者文件夹了。


```bash
Windows Registry Editor Version 5.00
 
[HKEY_CLASSES_ROOT\*\shell\SubLime]
@="edit with Sublime Text"
 
[HKEY_CLASSES_ROOT\*\shell\SubLime\Command]
@="E:\\Program Files\\Sublime Text 2\\sublime_text.exe \"%1\""
 
[HKEY_CLASSES_ROOT\Directory\shell\SubLime]
@="edit with Sublime Text"
 
[HKEY_CLASSES_ROOT\Directory\shell\SubLime\Command]
@="E:\\Program Files\\Sublime Text 2\\sublime_text.exe -a \"%1\""
```