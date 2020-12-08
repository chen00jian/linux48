---
title: CentOS上搭建私有maven仓库(迁移，升级)
date: 2015-11-12
tags:
- maven
- nexus
categories:
 - System
---




## 安装JDK

此处省略。。。

## 安装maven

```bash
wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz
tar zxvf apache-maven-3.5.0-bin.tar.gz
mv apache-maven-3.5.0  /usr/local/
echo "PATH=$PATH:/usr/local/apache-maven-3.5.0/bin/" >> /etc/profile
source /etc/profile
mvn -v
```

## 安装Sonatype Nexus

```bash
wget http://download.sonatype.com/nexus/oss/nexus-2.11.1-01-bundle.tar.gz
tar zxvf nexus-2.11.1-01-bundle.tar.gz 
mv nexus-2.11.1-01 /usr/local/nexus
```

## 配置Sonatype Nexus

```bash
vim /usr/local/nexus/conf/nexus.properties 

# Jetty section
application-port=8081 #访问端口
application-host=0.0.0.0
nexus-webapp=${bundleBasedir}/nexus  #程序目录
nexus-webapp-context-path=/nexus     #访问路径

# Nexus section
nexus-work=${bundleBasedir}/../sonatype-work/nexus #数据存放路径
runtime=${bundleBasedir}/nexus/WEB-INF
```


## Sonatype Nexus启动

```bash
cp /usr/local/nexus/bin/nexus /etc/init.d/nexus
vim /etc/init.d/nexus
#修改以下两个参数
NEXUS_HOME="/usr/local/nexus"
RUN_AS_USER=root
```

启动Nexus

```bash
chmod +x /etc/init.d/nexus
/etc/init.d/nexus start
```

centos7加入开机启动

```bash
[root@k8s-master nexus-3.17.0-01]# cat /usr/lib/systemd/system/nexus.service 
[Unit]
Description=nexus service
After=network.target
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/app/nexus/nexus-3.17.0-01/bin/nexus start
ExecStop=/app/nexus/nexus-3.17.0-01/bin/nexus stop
Restart=on-failure
[Install]
WantedBy=multi-user.target
[root@k8s-master nexus-3.17.0-01]# 

[root@k8s-master nexus-3.17.0-01]# systemctl daemon-reload
[root@k8s-master nexus-3.17.0-01]# systemctl enable nexus
[root@k8s-master nexus-3.17.0-01]# systemctl start nexus
```

nexus安装完成以后，一般在路径： http://sever_ip:8081/nexus/ 

打开以后会出现配置管理页面，说明安装成功了。点击右上角“Log in”，输入用户名和密码（默认用户名：admin密码：admin123）登录。


## 升级nexus3

后续要使用docker虚拟容器,需要把nexus2升级到nexus3

https://www.sonatype.com/download-oss-sonatype?hsCtaTracking=10655413-f621-4c62-be46-df84cf6b6b90%7C79f798b3-f0df-4370-b569-0eda6e14390e

由于最新版本`3.3.1-01`必须通过`2.14.4-03`版本升级(前面已经安装了`2.11.1`版本,尝试过`2.11.1`无法直接升级到`3.3.1-01`)

所以需要安装`2.14.4-03`版本过渡升级

### 安装nexus-2.14.4-03

```bash
# cd /opt/nexus/
# mkdir nexus-2.14.4
# cd nexus-2.14.4
# wget https://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-2.14.4-03-bundle.tar.gz
# tar zxvf nexus-2.14.4-03-bundle.tar.gz
# ll
总用量 71416
drwxr-xr-x. 8 root root     4096 4月   7 23:19 nexus-2.14.4-03
-rw-r--r--. 1 root root 73117829 5月  25 14:39 nexus-2.14.4-03-bundle.tar.gz
drwxr-xr-x. 3 root root     4096 5月  25 15:12 sonatype-work
# cd nexus-2.14.4-03
# vim bin/nexus
RUN_AS_USER=root
# vim conf/nexus.properties 
application-port=8082
# ./bin/nexus start
```

访问 http://10.10.3.225:8082/nexus

### 2.11.1迁移到2.14.4

2.X版本的nexus可以直接拷贝仓库目录进行迁移

拷贝2.11.1仓库目录到2.14.4-03

```bash
cd /usr/local/nexus-2.11.1/sonatype-work
tar zcvf nexus.tar.gz nexus/
scp nexus.tar.gz root@10.10.3.225:/opt/nexus/nexus-2.14.4/sonatype-work

# root@10.10.3.225

cd /opt/nexus/nexus-2.14.4/sonatype-work
rm -rf nexus
tar zxvf nexus.tar.gz
cd /opt/nexus/nexus-2.14.4/nexus-2.14.4-03
./bin/nexus restart
```

访问 http://10.10.3.225:8082/nexus 可以看到仓库已经迁移成功

### 安装nexus-3.3.1-01

```bash
# cd /opt/nexus/
# mkdir nexus-3.3.1
# cd nexus-3.3.1
# wget https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-3.3.1-01-unix.tar.gz
# tar zxvf nexus-3.3.1-01-unix.tar.gz
# ll
总用量 104836
drwxr-xr-x. 10 root root      4096 5月  25 11:58 nexus-3.3.1-01
-rw-r--r--.  1 root root 107336558 5月  25 10:46 nexus-3.3.1-01-unix.tar.gz
drwxr-xr-x.  3 root root      4096 5月  25 11:58 sonatype-work
# cd nexus-3.3.1-01
# vim etc/nexus-default.properties
application-port=8083
# ./bin/nexus start
```

访问 http://10.10.3.225:8083/nexus

### 迁移数据

#### 配置**nexus-2.14.4**的**Upgrade:Agent**

登陆 http://10.10.3.225:8082/nexus

Administration-->Capabilities-->New-->Upgrade: Agent-->Access Token-->12345678

上面的流程是登陆**nexus-2.14.4**配置`Upgrade:Agent`和`Access Token`在此我们配置的是12345678

#### 配置**nexus-3.3.1**的**Upgrade**

登陆 http://10.10.3.225:8083/nexus

Administration-->System-->Capabilities-->Create capability-->Create Upgrade Capability

#### 通过Task迁移数据

Administration-->System-->Upgrade-->Next-->URL&access token-->Next...

URL: http://10.10.3.225:8082/nexus
Access Token: 12345678

数据迁移完毕，验证仓库数据。

参考：

http://www.ilanni.com/?p=12366

https://www.cnblogs.com/liangyou666/p/9439755.html

https://www.cnblogs.com/sanduzxcvbnm/p/13100208.html

http://www.eryajf.net/1868.html
