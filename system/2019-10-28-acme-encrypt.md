---
title: 使用acme.sh脚本申请Let’s Encrypt域名SSL证书
date: 2019-10-28
tags:
- SSL
- https
- Let’s Encrypt
categories:
 - System
---

:::tip
[Let's Encrypt][1] 是一个由非营利性组织 [互联网安全研究小组][2]（ISRG）提供的免费、自动化和开放的证书颁发机构（CA）。

简单的说，借助 Let's Encrypt 颁发的证书可以为我们的网站免费启用 HTTPS(SSL/TLS) 。
:::


<!-- more -->


## Let's Encrypt 简介

由于前文[Startssl免费SSL证书+Nginx搭建https][8],Startssl关闭了,所以改换Let’s Encrypt域名SSL证书

Let's Encrypt免费证书的签发/续签都是脚本自动化的，官方提供了几种证书的申请方式方法，[点击此处][3] 快速浏览。

官方推荐使用 [Certbot][4] 客户端来签发证书，这种方式可参考文档自行尝试，不做评价。

我这里直接使用第三方客户端 [acme.sh][5] 申请，据了解这种方式可能是目前 Let's Encrypt 免费证书客户端最简单、最智能的 shell 脚本，可以自动发布和续订 Let's Encrypt 中的免费证书。

## 安装 acme.sh
安装很简单，一条命令：

```bash
# 以下命令请在Linux系统执行，root和普通用户均可安装：
curl https://get.acme.sh | sh
```

整个安装过程进行了以下几步，了解一下即可：

:::tip
1.把 acme.sh 安装到当前用户的主目录$HOME下的.acme.sh文件夹中，即~/.acme.sh/，之后所有生成的证书也会放在这个目录下；

2.创建了一个指令别名alias acme.sh=~/.acme.sh/acme.sh，这样我们可以通过acme.sh命令方便快速地使用 acme.sh 脚本；

3.自动创建cronjob定时任务, 每天 0:00 点自动检测所有的证书，如果快过期了，则会自动更新证书。
:::

安装命令执行完毕后，执行acme.sh --version确认是否能正常使用acme.sh命令。

```bash
[root@demo ~]$ acme.sh --version
https://github.com/Neilpang/acme.sh
v2.8.4
```

如有版本信息输出则表示环境正常；如果提示命令未找到，执行source ~/.bashrc命令重载一下环境配置文件。

整个安装过程不会污染已有的系统任何功能和文件，所有的修改都限制在安装目录~/.acme.sh/中。

据 acme.sh 官方文档介绍，其实现了 [acme][6] 协议支持的所有验证协议，一般有两种方式验证：http 和 dns 验证；也就是我们有两种选择签发证书

## 生成证书(http方式)

签发证书也很简单，一条命令：

```bash
acme.sh --issue -d linux48.com -d www.linux48.com -w /home/wwwroot/linux48.com
```

简单解释下这条命令涉及的几个参数：

:::tip
--issue是 acme.sh 脚本用来颁发证书的指令；

-d是--domain的简称，其后面须填写已备案的域名；

-w是--webroot的简称，其后面须填写网站的根目录。
:::

生成的证书放在了~/.acme.sh/linux48.com/目录。

```bash
[root@demo wwwroot]$ ll ~/.acme.sh/linux48.com/
total 32
-rw-rw-r-- 1 root root 1648 Oct 28 13:02 ca.cer
-rw-rw-r-- 1 root root 3567 Oct 28 13:02 fullchain.cer
-rw-rw-r-- 1 root root 1919 Oct 28 13:02 linux48.com.cer
-rw-rw-r-- 1 root root  563 Oct 28 13:02 linux48.com.conf
-rw-rw-r-- 1 root root  989 Oct 28 13:01 linux48.com.csr
-rw-rw-r-- 1 root root  224 Oct 28 13:01 linux48.com.csr.conf
-rw-rw-r-- 1 root root 1675 Oct 28 11:17 linux48.com.key
[root@demo wwwroot]$
```

另外，可以通过下面两个常用acme.sh命令查看和删除证书：

```bash
# 查看证书列表
acme.sh --list 

# 删除证书
acme.sh remove linux48.com
```
nginx SSL配置

```bash
    ssl_certificate      /home/demo/.acme.sh/linux48.com/fullchain.cer;
    ssl_certificate_key  /home/demo/.acme.sh/linux48.com/linux48.com.key;
```

## 生成泛域名证书(dns 验证)

目前泛域名证书仅支持DNS验证，acme.sh通过DNS提供商的API自动完成操作，因此需要先设置DNS API，以DNSPOD为例。

[登陆DNSPOD控制台创建密钥][7]，首次创建务必记录下token

```bash
#导入密钥
export DP_Id="122345"
export DP_Key="43cb8cc3123f94478c36gnjb94f5a8d562cd"
#申请证书
acme.sh --issue --dns dns_dp -d linux48.com -d '*.linux48.com'
```

如果提示

:::danger
[Mon Oct 28 11:26:49 CST 2019] *.linux48.com:Verify error:CAA record for *.linux48.com prevents issuance
:::

先暂停所有CNAME解析，方可成功。

### 其它常用DNS API设置

```bash
阿里云
#导入密钥
export Ali_Key="sdfsdfsdfljlbjkljlkjsdfoiwje"
export Ali_Secret="jlsdflanljkljlfdsaklkjflsa"
#申请证书
acme.sh --issue --dns dns_ali -d example.com -d www.example.com
```

```bash
CloudXNS
export CX_Key="1234"
export CX_Secret="sADDsdasdgdsf"
acme.sh --issue --dns dns_cx -d awk.sh -d *.awk.sh
```
```bash
CloudFlare
#导入密钥
export CF_Key="sdfsdfsdfljlbjkljlkjsdfoiwje"
export CF_Email="xxxx@sss.com"
#申请证书
acme.sh --issue --dns dns_cf -d example.com -d www.example.com
```

更多DNS API设置请参考：https://github.com/Neilpang/acme.sh/tree/master/dnsapi



## 更新证书
目前 Let's Encrypt 的证书有效期是90天，时间到了会自动更新，您无需任何操作。 今后有可能会缩短这个时间， 不过都是自动的，不需要您关心。

但是，您也可以强制续签证书：

```bash
# crontba -l
45 03 * * 1  acme.sh --renew -d linux48.com --force
```

## 更新 acme.sh
目前由于 acme 协议和 letsencrypt CA 都在频繁的更新, 因此 acme.sh 也经常更新以保持同步。

升级 acme.sh 到最新版：

```bash
acme.sh --upgrade
```

如果您不想手动升级,，可以开启自动升级：

```bash
acme.sh  --upgrade  --auto-upgrade
```

您也可以随时关闭自动更新：

```bash
acme.sh --upgrade  --auto-upgrade  0
```

参考

https://www.cnblogs.com/esofar/p/9291685.html

https://jszbug.com/zxaiacja34.html

https://github.com/Neilpang/acme.sh/wiki/%E8%AF%B4%E6%98%8E


  [1]: https://letsencrypt.org/
  [2]: https://letsencrypt.org/isrg/
  [3]: https://letsencrypt.org/docs/client-options/
  [4]: https://certbot.eff.org/
  [5]: https://github.com/Neilpang/acme.sh
  [6]: https://github.com/ietf-wg-acme/acme/
  [7]: https://console.dnspod.cn/account/token
  [8]: ./2016-05-24-free-ssl.html
