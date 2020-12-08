---
title: Gitlab-403-forbidden-并发引起IP被封
date: 2018-07-31
tags:
- gitlab
categories:
 - System
---

打开页面的时候显示的是空白页面Forbidden


# 原因

>* Gitlab使用rack_attack做了并发访问的限制。

# 解决方案

```bash
vim /etc/gitlab/gitlab.rb
```

>* 查找gitlab_rails['rack_attack_git_basic_auth']关键词；关闭rack_attack

enabled改为false

```bash
 gitlab_rails['rack_attack_git_basic_auth'] = {
   'enabled' => false,
   'ip_whitelist' => ["127.0.0.1","116.226.242.46"],
   'maxretry' => 10,
   'findtime' => 60,
   'bantime' => 3600
 }
```

>* 配置好后，执行gitlab-ctl reconfigure即可。
