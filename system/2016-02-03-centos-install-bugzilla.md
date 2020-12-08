---
title: CentOS下Nginx配置Perl运行Bugzilla
date: 2016-02-03
tags:
- perl
- bugzilla
categories:
 - System
---





# 安装LNMP

此处省略。。。

# 安装perl-fcgi模块

```bash
yum -y install perl-FCGI

#或者源码编译安装

wget http://search.cpan.org/CPAN/authors/id/F/FL/FLORA/FCGI-0.74.tar.gz
tar zxvf FCGI-0.74.tar.gz 
cd FCGI-0.74
perl Makefile.PL
make
make install
```


#新建perl脚本用做fastcgi进程管理，保存为/usr/bin/perl-fastcgi.pl

```bash

#! /bin/sh
#!/usr/bin/perl
 
use FCGI;
use Socket;
use POSIX qw(setsid);
 
require 'syscall.ph';
 
&daemonize;
 
#this keeps the program alive or something after exec'ing perl scripts
END() { } BEGIN() { }
*CORE::GLOBAL::exit = sub { die "fakeexit\nrc=".shift()."\n"; };
eval q{exit};
if ($@) {
    exit unless $@ =~ /^fakeexit/;
};
 
&main;
 
sub daemonize() {
    chdir '/'                 or die "Can't chdir to /: $!";
    defined(my $pid = fork)   or die "Can't fork: $!";
    exit if $pid;
    setsid                    or die "Can't start a new session: $!";
    umask 0;
}
 
sub main {
    #$socket = FCGI::OpenSocket( "127.0.0.1:8999", 10 ); #use IP sockets
        $socket = FCGI::OpenSocket( "/tmp/perl-fastcgi.sock", 10 ); #use IP sockets
        $request = FCGI::Request( \*STDIN, \*STDOUT, \*STDERR, \%req_params, $socket );
        if ($request) { request_loop()};
            FCGI::CloseSocket( $socket );
}
 
sub request_loop {
        while( $request->Accept() >= 0 ) {
 
           #processing any STDIN input from WebServer (for CGI-POST actions)
           $stdin_passthrough ='';
           $req_len = 0 + $req_params{'CONTENT_LENGTH'};
           if (($req_params{'REQUEST_METHOD'} eq 'POST') && ($req_len != 0) ){
                my $bytes_read = 0;
                while ($bytes_read < $req_len) {
                        my $data = '';
                        my $bytes = read(STDIN, $data, ($req_len - $bytes_read));
                        last if ($bytes == 0 || !defined($bytes));
                        $stdin_passthrough .= $data;
                        $bytes_read += $bytes;
                }
            }
 
            #running the cgi app
            if ( (-x $req_params{SCRIPT_FILENAME}) &&  #can I execute this?
                 (-s $req_params{SCRIPT_FILENAME}) &&  #Is this file empty?
                 (-r $req_params{SCRIPT_FILENAME})     #can I read this file?
            ){
        pipe(CHILD_RD, PARENT_WR);
        my $pid = open(KID_TO_READ, "-|");
        unless(defined($pid)) {
            print("Content-type: text/plain\r\n\r\n");
                        print "Error: CGI app returned no output - ";
                        print "Executing $req_params{SCRIPT_FILENAME} failed !\n";
            next;
        }
        if ($pid > 0) {
            close(CHILD_RD);
            print PARENT_WR $stdin_passthrough;
            close(PARENT_WR);
 
            while(my $s = <KID_TO_READ>) { print $s; }
            close KID_TO_READ;
            waitpid($pid, 0);
        } else {
                    foreach $key ( keys %req_params){
                       $ENV{$key} = $req_params{$key};
                    }
                    # cd to the script's local directory
                    if ($req_params{SCRIPT_FILENAME} =~ /^(.*)\/[^\/]+$/) {
                            chdir $1;
                    }
 
            close(PARENT_WR);
            close(STDIN);
            #fcntl(CHILD_RD, F_DUPFD, 0);
            syscall(&SYS_dup2, fileno(CHILD_RD), 0);
            #open(STDIN, "<&CHILD_RD");
            exec($req_params{SCRIPT_FILENAME});
            die("exec failed");
        }
            }
            else {
                print("Content-type: text/plain\r\n\r\n");
                print "Error: No such CGI app - $req_params{SCRIPT_FILENAME} may not ";
                print "exist or is not executable by this process.\n";
            }
 
        }
}
```

#新建init脚本，用于管理perl-fastcgi，保存为/etc/init.d/perl-fastcgi

```bash
#!/bin/sh
#
# nginx – this script starts and stops the nginx daemon
#
# chkconfig: - 85 15
# description: Nginx is an HTTP(S) server, HTTP(S) reverse \
# proxy and IMAP/POP3 proxy server
# processname: nginx
# config: /opt/nginx/conf/nginx.conf
# pidfile: /opt/nginx/logs/nginx.pid
 
# Source function library.
. /etc/rc.d/init.d/functions
 
# Source networking configuration.
. /etc/sysconfig/network
 
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
 
perlfastcgi="/usr/bin/perl-fastcgi.pl"
prog=$(basename perl)
 
lockfile=/var/lock/subsys/perl-fastcgi
 
start() {
    [ -x $perlfastcgi ] || exit 5
    echo -n $"Starting $prog: "
    daemon $perlfastcgi
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}
 
stop() {
    echo -n $"Stopping $prog: "
    killproc $prog -QUIT
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}
 
restart() {
    stop
    start
}
 
reload() {
    echo -n $”Reloading $prog: ”
    killproc $nginx -HUP
    RETVAL=$?
    echo
}
 
force_reload() {
    restart
}
rh_status() {
    status $prog
}
 
rh_status_q() {
    rh_status >/dev/null 2>&1
}
 
case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
    esac
```


#启动perl-fastcgi进程：

```bash
chmod +x /usr/bin/perl-fastcgi.pl 
chmod 755 /etc/init.d/perl-fastcgi
/etc/init.d/perl-fastcgi start
chkconfig perl-fastcgi on
```

#Nginx配置：

```bash
cat /usr/local/nginx/conf/vhost/bugzilla.com.conf


  server {
        listen       80;
        server_name bugzilla.e-buychina.com.cn;

        root   /app/www/bugzilla;
        index  index.cgi index.pl index.html index.htm;


        location ~ .*\.(pl|cgi)$ {
        root /app/www/bugzilla;
                gzip off;
                include fastcgi_params;
                fastcgi_pass  unix:/tmp/perl-fastcgi.sock;
                fastcgi_index index.cgi;
                fastcgi_param  SCRIPT_FILENAME  /$document_root/$fastcgi_script_name;
        }


   }
```

#新建index.pl脚本测试，加x执行权限。

```bash
#!/usr/bin/perl
print "Content-type: text/html\n\n";
print "<html><body>Hello, world.</body></html>";
```

如果正常就会显示Hello,world.


#安装bugzilla

```
tar xf bugzilla-5.0.2.tar.gz
cd bugzilla-5.0.1
./checksetup.pl --check-modules
perl install-module.pl --all
./checksetup.pl
vim localconfig
./checksetup.pl
chmod 755 -R *
```

#bugzilla发邮件

```bash
需要的Perl模块
Net::SMTP //perl自带，不用安装
Socket //perl自带，不用安装
Sys::Hostname //perl自带，不用安装
Authen::SASL （用使来验证邮件用户名和密码） //需要安装
使用root身份用如下命令来安装Authen::SASL模块：
root@server ~]# cpan Authen::SASL

测试模块是否安装：
[root@server1 ~]# perl -e "use Authen::SASL"

[root@server1 ~]# //什么也不显示表明模块已经正确安装了。

[root@server1 ~]# perl -e "use Net::SMTP"

[root@server1 ~]#

[root@server1 ~]# perl -e "use Socket"

[root@server1 ~]#

[root@server1 ~]# perl -e "use Sys::Hostname"

[root@server1 ~]#


vim  data/params.json 

'mailfrom' => 'xxx@163.com',
'smtp_password' => '***',
'smtp_username' => 'xxx@163.com',
'smtpserver' => 'smtp.163.com',
'urlbase' => 'http://192.168.0.2/bugzilla/',
```

#bugzilla忘记密码

```bash

SELECT ENCRYPT('123.com');

使用sql 生成 crypt来加密密文,填入数据库密码(cryptpassword)字段  `bugzilladb`.`profiles`表
```

