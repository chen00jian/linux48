---
title: 树莓派vim代码高亮
date: 2014-04-30
tags:
- RaspberryPi
categories:
 - RaspberryPi
---

# 树莓派vim代码高亮
==========

### 默认树莓派没有安装vim，执行下面命令安装之

    sudo apt-get install -y vim
    

### 安装好之后就可以使用vi或者vim进行编辑操作，但是没有代码高亮显示。

### 在~目录下面新建.vimrc文件可以实现

```bash
pi@raspberrypi ~ $ cd ~
pi@raspberrypi ~ $ vim .vimrc

set nu
syntax on
set tabstop=4
```

### 这样就ok了。
