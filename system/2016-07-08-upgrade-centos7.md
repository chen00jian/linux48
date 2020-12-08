---
title: 升级centos7.md
date: 2016-07-08
tags:
- centos
categories:
 - System
---

:::warning
本文只是玩玩，生产还是建议不要使用此法

如果产要使用centos7，直接光盘安装新服务器
:::

```
redhat提供了一个redhat-upgrade-tool的升级工具；

1.配置软件源

# vim /etc/yum.repos.d/upgrade.repo
[upgrade]
name=upgrade
baseurl=http://dev.centos.org/centos/6/upg/x86_64/
enable=1
gpgcheck=0

2. 安装升级工具包
# yum -y install preupgrade-assistant-contents redhat-upgrade-tool preupgrade-assistant


3.升级前检查潜在问题
# preupg

# preupg -l
如果结果为CentOS6_7 ，继续执行

# preupg -s CentOS6_7
这时候，会分析出升级系统潜在的危险。这里的危险具有等级性


4.导入 GPG KEY
# rpm --import http://mirror.centos.org/centos/7/os/x86_64/RPM-GPG-KEY-CentOS-7

5.升级系统

# centos-upgrade-tool-cli --network 7 --instrepo=http://mirror.centos.org/centos/7/os/x86_64/

这里，如果出现提示：具有危险导致无法升级，直接强制升级，慎重！！

# centos-upgrade-tool-cli -f --network 7 --instrepo=http://mirror.centos.org/centos/7/os/x86_64/

6.reboot

```

