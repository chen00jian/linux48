---
title: zabbix使用自动发现规则自动化监控redis多实例
date: 2017-02-28
tags:
- zabbix
- redis
categories:
 - Monitor
---

:::tip 
zabbix使用自动发现规则自动化监控redis多实例，废话不多说，直接撸代码。
:::

<!-- more -->



## zabbix-agent 配置

```bash
cat /usr/local/zabbix-agent/redis.sh

#!/bin/bash

redis() {
            port=($(sudo netstat -tpln | awk -F "[ :]+" '/redis/ && /0.0.0.0/ {print $5}'))
            printf '{\n'
            printf '\t"data":[\n'
               for key in ${!port[@]}
                   do
                       if [[ "${#port[@]}" -gt 1 && "${key}" -ne "$((${#port[@]}-1))" ]];then
              socket=`ps aux|grep ${port[${key}]}|grep -v grep|awk -F '=' '{print $10}'|cut -d ' ' -f 1`
                          printf '\t {\n'
                          printf "\t\t\t\"{#REDISPORT}\":\"${port[${key}]}\"},\n"
                     else [[ "${key}" -eq "((${#port[@]}-1))" ]]
              socket=`ps aux|grep ${port[${key}]}|grep -v grep|awk -F '=' '{print $10}'|cut -d ' ' -f 1`
                          printf '\t {\n'
                          printf "\t\t\t\"{#REDISPORT}\":\"${port[${key}]}\"}\n"
                       fi
               done
                          printf '\t ]\n'
                          printf '}\n'
}
$1
```

由于此脚本需要使用zabbix用户调用`netstat`命令，故需要允许zabbix用户无密码运行，同时关闭`requiretty`

然后给与755权限，并修改用户与组为zabbix
<!-- more -->


```bash
echo "zabbix ALL=(root) NOPASSWD:/bin/netstat">>/etc/sudoers
sed -i 's/^Defaults.*.requiretty/#Defaults    requiretty/' /etc/sudoers
chmod 755 /usr/local/zabbix-agent/etc/redis.sh
chown -R zabbix.zabbix /usr/local/zabbix-agent/etc/redis.sh
```

添加UserParameter

```bash
[root@redis conf]# cat /usr/local/zabbix-agent/etc/zabbix_agentd.conf
UnsafeUserParameters=1
UserParameter=zabbix_low_discovery[*],sh /usr/local/zabbix-agent/etc/redis.sh $1
UserParameter=redis_stats[*],(echo info; sleep 1) | telnet 127.0.0.1 $1   2>&1 |grep -w $2|cut -d : -f2
```

## 实现原理

自动发现规则**zabbix_low_discovery**
```bash
[root@redis conf]# su zabbix
[zabbix@redis conf]$ sh /usr/local/zabbix-agent/etc/redis.sh redis
{
        "data":[
         {
                        "{#REDISPORT}":"6379"},
         {
                        "{#REDISPORT}":"26379"},
         {
                        "{#REDISPORT}":"16379"}
         ]
}
[zabbix@redis conf]$ 
```

**redis_stats**的**item**获取利用**telnet**端口格式化各项参数信息
```bash
[root@redis conf]# su zabbix
[zabbix@zhenru025 conf]$ (echo info; sleep 1) | telnet 127.0.0.1 6379   2>&1 |grep -w used_memory|cut -d : -f2   
25109752
```

## zabbix_server 配置

使用zabbix_get获取zabbix_agent的redis键值

```bash
[root@zabbix ebuy]# /usr/local/zabbix-server/bin/zabbix_get -s 10.10.10.3 -k zabbix_low_discovery[redis]
{
        "data":[
         {
                        "{#REDISPORT}":"6379"},
         {
                        "{#REDISPORT}":"26379"},
         {
                        "{#REDISPORT}":"16379"}
         ]
}
[root@zabbix ebuy]# 
[root@zabbix ebuy]# /usr/local/zabbix-server/bin/zabbix_get -s 10.10.10.3 -k redis_stats[6379,total_connections_received] 
63711
```

以上配置完毕，测试没问题就万事俱备，导入**[模板][1]**就OK！

至于网上一些文章说还需要设置正则表达式

```bash
设置正则
在“管理”—> “一般”—>“正则表达式”里，选择“新的正则表达式”
设置如下(填写所有redis的端口号)：
name：Redis regex
Result TRUE  = ^(6380|6381)$
```

我使用的是**Zabbix 3.2.3**版本，不用设置正则也可以。

## 监控图像

可根据自身业务需求设置相应的触发器报警机制。

![][2]


  [1]: http://pan.baidu.com/s/1eSIamJK
  [2]: ../images/Ztd9BI5jlb1kpLc.jpg
