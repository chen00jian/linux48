---
title: centos install oracle 11g
date: 2012-12-20
tags:
- oracle
categories:
 - Database
---




**一、运行环境**  
系统环境：centos 6.2 64位(图形安装)

#硬盘分区

<pre class="lang:default decode:true">/boot 150M
 /swap 4096M(最少要3G以上)
 / 10G
 /home 5G
 /tmp 5G
 /usr 10G
 /usr/local 10G
 /var 10G
 /opt 10G
 /data 剩余所有</pre>

#同步时钟 
yum -y install ntp  
ntpdate time.nist.gov  
echo &#8220;\* \*/2 \* \* * /sbin/ntpdate time.nist.gov&#8221; >> /etc/crontab

**二、安装oracle 11gR2 依赖的组件包**  
yum -y install binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel glibc glibc-common glibc-devel gcc gcc-c++ libaio-devel libaio libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel pdksh numactl-devel glibc-headers  
/sbin/ldconfig

**三、调整内核参数**

vi /etc/sysctl.conf

<pre class="lang:default decode:true">fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 536870912
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
fs.aio-max-nr = 1048576</pre>

#让内核参数生效  
sysctl -p

#修改limits.conf

vi /etc/security/limits.conf

<pre class="lang:default decode:true">#oracle settings
oracle           soft    nproc   2047
oracle           hard    nproc   16384
oracle           soft    nofile  1024
oracle           hard    nofile  65536</pre>

#修改系统版本（Redhat 5.×系列系统略过这步）

cp /etc/redhat-release /etc/redhat-release.bk

vi /etc/redhat-release

<pre class="lang:default decode:true">#修改内容为：
Red Hat Enterprise Linux AS release 5 (Taroon)</pre>

#修改/etc/pam.d/login  
#添加以下内容：

<pre class="lang:default decode:true">session    required     /lib/security/pam_limits.so
session    required     pam_limits.so</pre>

#修改/etc/profile  
vi /etc/profile

<pre class="lang:default decode:true">#添加以下内容：
 if [ $USER = "oracle" ]; then
    if [ $SHELL = "/bin/ksh" ]; then
       ulimit -p 16384
       ulimit -n 65536
    else
       ulimit -u 16384 -n 65536
    fi
 fi</pre>

#修改/etc/csh.login  
vi /etc/csh.login

<pre class="lang:default decode:true">#添加以下内容:
 if ( $USER == "oracle" ) then
      limit maxproc 16384
      limit deors 65536
 endif</pre>

**四、创建oracle用户**

groupadd oinstall  
groupadd dba  
useradd -g oinstall -G dba oracle  
passwd oracle     #753951

mkdir -p /data/oracle  
mkdir -p /data/oralnventory  
mkdir -p /data/software  
chown -R oracle:oinstall /data/oracle  
chown -R oracle:oinstall /data/software  
chown -R oracle:oinstall /data/oralnventory

#设置用户环境变量  
#su &#8211; oracle

vi .bash_profile

<pre class="lang:default decode:true">#添加以下内容
ORACLE_SID=kerry; export ORACLE_SID
ORACLE_BASE=/data/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1; export ORACLE_HOME
PATH=$PATH:$ORACLE_HOME/bin:$HOME/bin; export PATH</pre>

source .bash_profile

**五、安装oracle**

#上传oracle安装文件到/data/software目录下，并解压

cd /data/software

unzip linux.x64\_11gR2\_database_1of2.zip  
unziplinux.x64\_11gR2\_database_1of2.zip

xhost +   #(这里使用root用户执行,一定要执行以下2步，如果没有执行，将无法启动图形安装界面)  
xhost + localhost  
su &#8211; oralce  
cd /data/software/database  
./runInstaller  #(到oracle安装文件所在目录执行该命令)

&#8230;&#8230;

直接填写相关信息，到最后一步需要用root用户执行脚本

su root

/data/oralnventory/orainstRoot.sh

/data/oracle/product/11.2.0/db_1/root.sh

**六、开机启动设置**

#自动启动和关闭数据库实例和监听  
vi /oracle/oracle/product/11.2.0/db_1/bin/dbstart

<pre class="lang:default decode:true">ORACLE_HOME_LISTNER=$1
#修改为：
ORACLE_HOME_LISTNER=$ORACLE_HOME</pre>

#启动脚本

vi /etc/init.d/oracle

<pre class="lang:default decode:true">#!/bin/sh
 # chkconfig: 345 61 61
 # description: Oracle 11g AutoRun Services
 # /etc/init.d/oracle
 #
 # Run-level Startup script for the Oracle Instance, Listener, and
 # Web Interface
 export ORACLE_BASE=/data/oracle
 export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
 export ORACLE_SID=kerry
 export PATH=$PATH:$ORACLE_HOME/bin
 ORA_OWNR="oracle"
 # if the executables do not exist -- display error

 if [ ! -f $ORACLE_HOME/bin/dbstart -o ! -d $ORACLE_HOME ]
 then
      echo "Oracle startup: cannot start"
      exit 1
 fi
 # depending on parameter -- startup, shutdown, restart
 # of the instance and listener or usage display
 case "$1" in
  start)
      # Oracle listener and instance startup
      su $ORA_OWNR -lc $ORACLE_HOME/bin/dbstart
      echo "Oracle Start Succesful!OK."
      ;;
  stop)
      # Oracle listener and instance shutdown
      su $ORA_OWNR -lc $ORACLE_HOME/bin/dbshut
      echo "Oracle Stop Succesful!OK."
      ;;
  reload|restart)
      $0 stop
      $0 start
      ;;
  *)
      echo $"Usage: `basename $0` {start|stop|reload|reload}"
      exit 1
 esac
 exit 0</pre>

chmod 750 /etc/init.d/oracle  
ln -s /etc/init.d/oracle /etc/rc1.d/K61oracle  
ln -s /etc/init.d/oracle /etc/rc3.d/S61oracle  
chkconfig &#8211;level 345 oracle on  
chkconfig &#8211;add oracle

#启动oracle  
service oracle start

#查看oracle端口

netstat -nat

1521端口

#自动启动和关闭 EM

vi /etc/init.d/oraemctl

<pre class="lang:default decode:true">#!/bin/sh
 # chkconfig: 345 61 61
 # description: Oracle 11g AutoRun Services
 # /etc/init.d/oraemctl
 #
 # Run-level Startup script for the Oracle Instance, Listener, and
 # Web Interface
 export ORACLE_BASE=/data/oracle
 export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
 export ORACLE_SID=kerry
 export PATH=$PATH:$ORACLE_HOME/bin
 ORA_OWNR="oracle"
 case "$1" in
 start)
 echo -n $"Starting Oracle EM DB Console:"
 su - $ORACLE_OWNER -c "$ORACLE_HOME/bin/emctl start dbconsole"
 echo "OK"
 ;;
 stop)
 echo -n $"Stopping Oracle EM DB Console:"
 su - $ORACLE_OWNER -c "$ORACLE_HOME/bin/emctl stop dbconsole"
 echo "OK"
 ;;
 *)
 echo $"Usage: $0 {start|stop}"
 esac</pre>

chmod 750 /etc/init.d/oraemctl  
#启动EM  
service oraemctl start

**七、**创建实例进行测试****

su &#8211; oracle

sqlplus / as sysdba

SQL> startup

<div align="left">
  SQL> create table test ( id integer , name char(10));
</div>

<div align="left">
  SQL> insert into testbl values ( 0 , &#8216;frank&#8217; );
</div>

<div align="left">
  SQL> commit;
</div>

<div align="left">
  SQL> select * from test;
</div>

<div align="left">
  SQL> shutdown immediate
</div>

<div align="left">
  SQL> exit
</div>
