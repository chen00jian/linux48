---
title: centos下snmp客户端安装
date: 2012-04-11
tags:
- snmp
categories:
 - System
---



centos下snmp客户端安装

    yum -y install net-snmp
    vi /etc/snmp/snmpd.conf


#定义一个共同体名称community,这里是public,及可以访问这个public的用户名这里是#notConfigUser,public相当于密码

    com2sec notConfigUser default public

#定义一个组名这里是notConfigGroup,及组的安全级别,把notConfigGroup这个用户加到这个组中

    group notConfigGroup v1 notConfigUser  
    group notConfigGroup v2c notConfigUser

#定义一个可操作的视图view名,这里是all,范围是.1

    view systemview included .1

定义notConfigUser这个组在all这个视图范围内可做的操作

    access notConfigGroup "" any noauth exact systemview none none

#管理员的一些信息

    syslocation www.uintec.com  
    syscontact maxiaolei (xiaolei.ma@uintec.com)  
    dontLogTCPWrappersConnects yes[/php]
    iptables -A INPUT -p udp &#8211;dport 161 -j ACCEPT
    service snmpd restart
    /etc/rc.d/init.d/iptables restart

验证：在另一台主机安装net-snmp-utils（SNMP信息采集包）

    yum install net-snmp-utils

    snmpwalk -v 1 192.168.1.1 -c public system

出现下面信息则说明 SNMP 已经正常工作了

```bash
SNMPv2-MIB::sysDescr.0 = STRING: Linux localhost.localdomain 2.6.18-194.el5PAE #1 SMP Fri Apr 2 15:37:44 EDT 2010 i686  
SNMPv2-MIB::sysObjectID.0 = OID: NET-SNMP-MIB::netSnmpAgentOIDs.10  
DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (412562541) 47 days, 18:00:25.41  
SNMPv2-MIB::sysContact.0 = STRING: maxiaolei (xiaolei.ma@uintec.com)  
SNMPv2-MIB::sysName.0 = STRING: localhost.localdomain  
SNMPv2-MIB::sysLocation.0 = STRING: www.uintec.com  
SNMPv2-MIB::sysORLastChange.0 = Timeticks: (1) 0:00:00.01  
SNMPv2-MIB::sysORID.1 = OID: SNMPv2-MIB::snmpMIB  
SNMPv2-MIB::sysORID.2 = OID: TCP-MIB::tcpMIB  
SNMPv2-MIB::sysORID.3 = OID: IP-MIB::ip  
SNMPv2-MIB::sysORID.4 = OID: UDP-MIB::udpMIB  
SNMPv2-MIB::sysORID.5 = OID: SNMP-VIEW-BASED-ACM-MIB::vacmBasicGroup  
SNMPv2-MIB::sysORID.6 = OID: SNMP-FRAMEWORK-MIB::snmpFrameworkMIBCompliance  
SNMPv2-MIB::sysORID.7 = OID: SNMP-MPD-MIB::snmpMPDCompliance  
SNMPv2-MIB::sysORID.8 = OID: SNMP-USER-BASED-SM-MIB::usmMIBCompliance  
SNMPv2-MIB::sysORDescr.1 = STRING: The MIB module for SNMPv2 entities  
SNMPv2-MIB::sysORDescr.2 = STRING: The MIB module for managing TCP implementations  
SNMPv2-MIB::sysORDescr.3 = STRING: The MIB module for managing IP and ICMP implementations  
SNMPv2-MIB::sysORDescr.4 = STRING: The MIB module for managing UDP implementations  
SNMPv2-MIB::sysORDescr.5 = STRING: View-based Access Control Model for SNMP.  
SNMPv2-MIB::sysORDescr.6 = STRING: The SNMP Management Architecture MIB.  
SNMPv2-MIB::sysORDescr.7 = STRING: The MIB for Message Processing and Dispatching.  
SNMPv2-MIB::sysORDescr.8 = STRING: The management information definitions for the SNMP User-based Security Model.  
SNMPv2-MIB::sysORUpTime.1 = Timeticks: (0) 0:00:00.00  
SNMPv2-MIB::sysORUpTime.2 = Timeticks: (0) 0:00:00.00  
SNMPv2-MIB::sysORUpTime.3 = Timeticks: (0) 0:00:00.00  
SNMPv2-MIB::sysORUpTime.4 = Timeticks: (0) 0:00:00.00  
SNMPv2-MIB::sysORUpTime.5 = Timeticks: (0) 0:00:00.00  
SNMPv2-MIB::sysORUpTime.6 = Timeticks: (1) 0:00:00.01  
SNMPv2-MIB::sysORUpTime.7 = Timeticks: (1) 0:00:00.01  
SNMPv2-MIB::sysORUpTime.8 = Timeticks: (1) 0:00:00.01
```