---
title: dbfmpi——树莓派豆瓣电台fm发射器
date: 2013-02-23
tags:
- RaspberryPi
categories:
 - RaspberryPi
---




1、使用前需要安装mpg123

```bash
sudo apt-get install mgp123
```

2、GPIO4连接导线作为发射天线

3、克隆项目

```bash
git clone https://github.com/koy1619/dbfmpi.git
```

4、运行

```bash
sudo python fmpi.py
```

5、默认调频97.0，可在config.py内修改


参考项目：

DoubanFM-CLI [https://github.com/zztczcx/DoubanFM-CLI](https://github.com/zztczcx/DoubanFM-CLI)

fmpi [https://github.com/ma6174/fmpi](https://github.com/ma6174/fmpi)


PS:目前的代码就是以上两个项目的简单整合，各种不稳定是肯定的。
