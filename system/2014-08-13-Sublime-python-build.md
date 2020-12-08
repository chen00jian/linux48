---
title: Sublime Text 3设置python编译支持环境设置
date: 2014-08-13
tags:
- sublime
- python
categories:
 - System
---




这里主要解决Sublime中运行带`input`或`raw_input`的Python代码出错：`EOFError: EOF when reading a line`

快捷键：Ctrl+`，打开Sublime的console:

输入下面代码

    import urllib2,os; pf='Package Control.sublime-package'; ipp=sublime.installed_packages_path(); os.makedirs(ipp) if not os.path.exists(ipp) else None; urllib2.install_opener(urllib2.build_opener(urllib2.ProxyHandler())); open(os.path.join(ipp,pf),'wb').write(urllib2.urlopen('http://sublime.wbond.net/'+pf.replace(' ','%20')).read()); print('Please restart Sublime Text to finish installation')


安装`sublimerepl`插件

按键绑定配置加入

```bash
    { "keys": ["alt+q"], "command": "repl_open", 
                 "caption": "Python",
                 "mnemonic": "p",
                 "args": {
                 "type": "subprocess",
                 "encoding": "utf8",
                 "cmd": ["python", "-i", "-u", "$file"],
                 "cwd": "$file_path",
                 "syntax": "Packages/Python/Python.tmLanguage",
                 "external_id": "python"
                 } 
    }
```

这样子就可以直接使用`alt+q`进行编译和调试。

