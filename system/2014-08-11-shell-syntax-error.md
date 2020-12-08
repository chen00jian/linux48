---
title: SHELL syntax error:unexpected end of file 提示错误
date: 2014-08-11
tags:
- shell
categories:
 - System
---



linux下执行`sh test.sh`提示`syntax error:unexpected end of file`


因为脚本是在windows下通过sublime编写的，然后upload到linux服务器。

解决思路：

> * DOS下文件和Linux下文件格式差异问题导致的。

> * DOS下的文本文件是以\r\n作为断行标志的，表示成十六进制就是0D 0A。而Unix下的文本文件是以\n作为断行标志的，表示成十六进制就是0A。

> * 在windows里,换行用的两个符号，回车\r，换行符号\n，在linux下只需一个符号\n就可以了。

> * DOS格式的文本文件在Linux下，用较低版本的vi打开时行尾会显示^M，当然也有可能看不到，但是在vi的时候，会在下面显示此文件的格式，"M.txt" [dos] 8L, 72C表示是一个dos文件格式。

解决方案：

使用下面的命令将文件格式设置为unix格式即可解决上述错误。

    vim test.sh
    :set fileformat=unix  #或者:set ff=unix
    :wq


unix转dos同理

    vim test.sh
    :set ff=dos
    :wq
