---
title: journalctl日志管理工具
date: 2017-05-25
tags:
- log
- journalctl
categories:
 - System
---


::: tip
日志管理工具journalctl是centos7上专有的日志管理工具，该工具是从message这个文件里读取信息。Systemd统一管理所有Unit的启动日志。带来的好处就是，可以只用journalctl一个命令，查看所有日志（内核日志和应用日志）。
日志的配置文件是: /etc/systemd/journald.conf
journalctl功能强大，用法非常多。

详见：http://www.jinbuguo.com/systemd/journalctl.html
:::

本文将介绍journalctl的常用使用方法。

<!-- more -->

查看所有日志
默认情况下，只保存本次启动的日志

    journalctl

查看内核日志（不显示应用日志）

    journalctl -k
	
查看系统本次启动的日志

    journalctl   -b
    journalctl  -b  -0

查看上一次启动的日志需更改设置,如上次系统崩溃，需要查看日志时，就要看上一次的启动日志。

    journalctl  -b -1

查看指定时间的日志

    journalctl --since="2012-10-3018:17:16"
    journalctl --since "20 minago"
    journalctl --since yesterday
    journalctl --since"2015-01-10" --until "2015-01-11 03:00"
    journalctl --since 09:00 --until"1 hour ago"
    journalctl --since"15:15" --until now

显示尾部的最新10行日志

    journalctl  -n 10


实时滚动显示最新日志

    journalctl   -f

查看指定服务的日志

    journalctl  /usr/lib/systemd/systemd

查看指定进程的日志

    journalctl   _PID=1

查看某个路径的脚本的日志

    journalctl    /usr/bin/bash

查看指定用户的日志

    journalctl _UID=33  --since today

查看某个Unit的日志

    journalctl  -u nginx.service
    journalctl  -u nginx.service  --since  today

实时滚动显示某个Unit的最新日志

    journalctl  -u nginx.service  -f

合并显示多个Unit的日志

    journalctl  -u nginx.service  -u php-fpm.service  --since today

查看指定优先级（及其以上级别）的日志
日志优先级共有8级

>* 0: emerg
>* 1: alert
>* 2: crit
>* 3: err
>* 4: warning
>* 5: notice
>* 6: info
>* 7: debug

显示不同级别的日志：

    journalctl  -p err  -b
    journalctl  -p err..alert -b


不分页标准输出日志
默认情况下，结果会通过 less 工具进行分页输出， 并且超长行会在屏幕边缘被截断。
journalctl 会在 pager 内显示输出结果。如果希望利用文本操作工具对数据进行处理，则需要使用标准输出。在这种情况下，我们需要使用 --no-pager 选项。

    journalctl  --no-pager

以JSON格式（单行）输出

    journalctl  -b -u httpd.service  -o json

以JSON格式（多行）输出，可读性更好，建议选择多行输出

    journalctl  -b -u httpd.service  -o json-pretty

显示日志占据的硬盘空间

    journalctl  --disk-usage

指定日志文件占据的最大空间

    journalctl   --vacuum-size=1G

指定日志文件保存多久

    journalctl   --vacuum-time=1years

清理日志数据

如果打算对 journal 记录进行清理，则可使用两种不同方式。

>* 使用 –vacuum-size 选项
>* 使用 –vacuum-time 选项

如果使用 –vacuum-size 选项，则可硬性指定日志的总体体积，意味着其会不断删除旧有记录直到所占容量符合要求：

    journalctl --vacuum-size=1G

另一种方式则是使用 –vacuum-time 选项。任何早于这一时间点的条目都将被删除。例如，去年之后的条目才能保留：

    journalctl --vacuum-time=1years
