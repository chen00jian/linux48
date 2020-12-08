---
title: haproxy-keepalived安装.md
date: 2017-02-03
tags:
- haproxy
- keepalived
categories:
 - System
---

-------------------------
haproxy 安装

```bash
wget http://www.haproxy.org/download/1.5/src/haproxy-1.5.14.tar.gz
tar zxvf haproxy-1.5.14.tar.gz 
cd haproxy-1.5.14
tar zxvf haproxy-1.5.14.tar.gz 
cd haproxy-1.5.14
make TARGET=linux26 ARCH=x86_64 PREFIX=/usr/local/haproxy
make install PREFIX=/usr/local/haproxy
mkdir -p /usr/local/haproxy/etc

##热加载
/usr/local/haproxy/sbin/haproxy   -D -f /usr/local/haproxy/etc/haproxy.cfg -p /usr/local/haproxy/haproxy.pid  -sf 22942

cat /usr/local/haproxy/etc/haproxy.cfg 
global
    log         /dev/log  local2

    pidfile     /usr/local/haproxy/haproxy.pid
    maxconn     8000
    user        haproxy
    group       haproxy
    daemon
    stats socket /usr/local/haproxy/haproxy.sock mode 0600 level admin

defaults
    mode                    tcp
    log                     global
#    option                  logasap
    retries                 3
#    timeout queue           30s
    timeout connect         10s
    timeout client          300s
    timeout server          300s
    timeout check           10s
    maxconn                 8000
    log-format              %ci:%cp\ [%t]\ %ft\ %b[%bi:%bp]/%s[%si:%sp]\ %Tw/%Tc/%Tt\ %U/%B\ %ts\ %ac/%fc/%bc/%sc/%rc\ %sq/%bq

listen  haproxy_stats
    mode http
    bind 172.16.0.43:6333
    option httplog
    maxconn 10
    stats enable
    stats hide-version
    stats refresh 30s
    stats show-node
    stats auth admin:i6qcmEl43bHEB9k1
    stats uri /haproxy?stats

listen consumer
    mode tcp
    balance roundrobin
    #banlance roundrobin 轮询，balance source 保存session值，支持static-rr，leastconn，first，uri等参数
    bind 172.16.0.43:4010
    server consumer44  172.16.0.44:8030 weight 1 check inter 2000 rise 5 fall 10
    server consumer56  172.16.0.56:8030 weight 1 check inter 2000 rise 5 fall 10
    server consumer43  172.16.0.43:8030 weight 1 check inter 2000 rise 5 fall 10
    # weight - 调节服务器的负重
    # check - 允许对该服务器进行健康检查
    # inter - 设置连续的两次健康检查之间的时间，单位为毫秒(ms)，默认值 2000(ms)
    # rise - 指定多少次连续成功的健康检查后，即可认定该服务器处于可操作状态，默认值 2
    # fall - 指定多少次不成功的健康检查后，认为服务器为当掉状态，默认值 3
    # maxconn - 指定可被发送到该服务器的最大并发连接数




cat /etc/init.d/haproxy 
#!/bin/sh
#
# haproxy
#
# chkconfig:   - 85 15
# description:  HAProxy is a free, very fast and reliable solution \
#               offering high availability, load balancing, and \
#               proxying for TCP and  HTTP-based applications
# processname: haproxy
# config:      /usr/local/haproxy/etc/haproxy.cfg
# pidfile:     /usr/local/haproxy/etc/haproxy.pid

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

dir="/usr/local/haproxy"
exec="$dir/sbin/haproxy"
prog=$(basename $exec)

[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

lockfile=/var/lock/subsys/haproxy

check() {
    $exec -c -V -f $dir/etc/$prog.cfg
}

start() {
    $exec -c -q -f $dir/etc/$prog.cfg
    if [ $? -ne 0 ]; then
        echo "Errors in configuration file, check with $prog check."
        return 1
    fi

    echo -n $"Starting $prog: "
    # start it up here, usually something like "daemon $exec"
    daemon $exec -D -f $dir/etc/$prog.cfg -p $dir/$prog.pid
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    # stop it here, often "killproc $prog"
    killproc $prog 
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    $exec -c -q -f $dir/etc/$prog.cfg
    if [ $? -ne 0 ]; then
        echo "Errors in configuration file, check with $prog check."
        return 1
    fi
    stop
    start
}

reload() {
    $exec -c -q -f $dir/etc/$prog.cfg
    if [ $? -ne 0 ]; then
        echo "Errors in configuration file, check with $prog check."
        return 1
    fi
    echo -n $"Reloading $prog: "
    $exec -D -f $dir/etc/$prog.cfg -p $dir/$prog.pid -sf $(cat $dir/$prog.pid)
    retval=$?
    echo
    return $retval
}

force_reload() {
    restart
}

fdr_status() {
    status $prog
}

case "$1" in
    start|stop|restart|reload)
        $1
        ;;
    force-reload)
        force_reload
        ;;
    check)
        check
        ;;
    status)
        fdr_status
        ;;
    condrestart|try-restart)
        [ ! -f $lockfile ] || restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|try-restart|reload|force-reload}"
        exit 2
esac



vim /etc/rsyslog.conf
# Include all config files in /etc/rsyslog.d/
$IncludeConfig /etc/rsyslog.d/*.conf


cat /etc/rsyslog.d/haproxy.conf 
#if ($programname == 'haproxy' and $syslogseverity-text == 'info') then -/var/log/haproxy/haproxy-info.log
#& ~
#if ($programname == 'haproxy' and $syslogseverity-text == 'notice') then -/var/log/haproxy/haproxy-notice.log
#& ~
local2.*                       /var/log/haproxy.log
& ~

groupadd haproxy
useradd -g haproxy haproxy
usermod -s /sbin/nologin haproxy

/etc/init.d/rsyslog restart
/etc/init.d/haproxy restart
```
haproxy log 日切脚本

```bash
[root@zhenru058 ~]# cat cut_haproxy_log.sh 
#!/bin/bash
# This script run at 00:00
                                         
# The haproxy log path
LOGPATH="/var/log"
BAKPATH="/data/halogbak"
                                         
#[[ -z `ps aux | grep sbin/haproxy | grep -v grep` ]] && exit 1
mv ${LOGPATH}/haproxy.log ${BAKPATH}/haproxy_$(date -d "yesterday" +"%Y-%m-%d").log
/etc/init.d/rsyslog restart
```

----------------------------
keepalived安装

```bash
wget http://www.keepalived.org/software/keepalived-1.2.19.tar.gz
tar zxvf keepalived-1.2.19.tar.gz 
cd keepalived-1.2.19
./configure --prefix=/usr/local/keepalived
make
make install

cd /usr/local/keepalived/etc/
cp rc.d/init.d/keepalived  /etc/init.d/
cp sysconfig/keepalived /etc/sysconfig/
cp keepalived/keepalived.conf  /usr/local/keepalived/etc/

cat /etc/init.d/keepalived 
#!/bin/sh
#
# Startup script for the Keepalived daemon
#
# processname: keepalived
# pidfile: /usr/local/keepalived/keepalived.pid
# config: /usr/local/keepalived/etc/keepalived.conf
# chkconfig: - 21 79
# description: Start and stop Keepalived

# Source function library
. /etc/rc.d/init.d/functions

# Source configuration file (we set KEEPALIVED_OPTIONS there)
. /etc/sysconfig/keepalived

RETVAL=0

prog="keepalived"

start() {
    echo -n $"Starting $prog: "
    daemon keepalived ${KEEPALIVED_OPTIONS}
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && touch /var/lock/subsys/$prog
}

stop() {
    echo -n $"Stopping $prog: "
    killproc keepalived
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/$prog
}

reload() {
    echo -n $"Reloading $prog: "
    killproc keepalived -1
    RETVAL=$?
    echo
}

# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    reload)
        reload
        ;;
    restart)
        stop
        start
        ;;
    condrestart)
        if [ -f /var/lock/subsys/$prog ]; then
            stop
            start
        fi
        ;;
    status)
        status keepalived
        RETVAL=$?
        ;;
    *)
        echo "Usage: $0 {start|stop|reload|restart|condrestart|status}"
        RETVAL=1
esac

exit $RETVAL


chmod 777 /etc/init.d/keepalived 
cp /usr/local/keepalived/sbin/keepalived /usr/bin/
cp /usr/local/keepalived/sbin/keepalived /usr/sbin/
/etc/init.d/keepalived  start


vim /etc/sysconfig/keepalived
KEEPALIVED_OPTIONS="-D -d -S 0 -f /usr/local/keepalived/etc/keepalived.conf"


vim /etc/rsyslog.conf
#keepalived -S 0
local0.* /var/log/keepalived.log

/etc/init.d/rsyslog restart
/etc/init.d/keepalived restart
tail -f /var/log/haproxy.log 
```

