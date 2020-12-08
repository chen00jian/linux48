---
title: ruby环境sass编译中文出现 Invalid GBK character
date: 2015-01-07
tags:
- ruby
categories:
 - System
---




sass文件编译时候使用ruby环境，无论是界面化的koala工具还是命令行模式的都无法通过，真是令人烦恼。

容易出现中文注释时候无法编译通过，或者出现乱码，找了几天的解决方法终于解决了。

这个问题的奇葩之处在于在xp环境中没有任何问题，只是在windows7环境中才出现的这个。

sass编译时候出现如下错误的解决方法：


    Syntax error: Invalid GBK character "\xE5"


解决办法：


找到ruby的安装目录，里面也有sass模块，如这个路径：

    C:\Ruby21-x64\lib\ruby\gems\2.1.0\gems\sass-3.4.8\lib\sass.rb

在这个文件里面engine.rb，添加一行代码（同方法1）

    Encoding.default_external = Encoding.find('utf-8')
    
放在所有的require XXXX 之后即可。

参考： https://github.com/imathis/octopress/issues/232