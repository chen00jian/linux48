---
title: CISCO ASA5520 HA 配置
date: 2016-04-14
tags:
- cisco
categories:
 - System
---





#主防火墙配置

##接口配置

```
interface GigabitEthernet0/0
 nameif outside
 security-level 0
 ip address 192.168.2.226 255.255.255.0 standby 192.168.2.241 
!
interface GigabitEthernet0/1
 nameif inside
 security-level 100
 ip address 192.168.100.1 255.255.255.0 standby 192.168.100.4 
!             
interface GigabitEthernet0/2
 description STATE Failover Interface
!
interface GigabitEthernet0/3
 description LAN Failover Interface
```


##HA配置

```
failover lan unit primary

failover lan interface HA GigabitEthernet0/3
failover interface ip HA 10.10.10.1 255.255.255.0 standby 10.10.10.2

failover link stateful GigabitEthernet0/2
failover interface ip stateful 10.10.11.1 255.255.255.252 standby 10.10.11.2

failover
```


#备防火墙配置

**HA配置**

```
failover lan unit secondary

failover lan interface HA GigabitEthernet0/3
failover interface ip HA 10.10.10.1 255.255.255.0 standby 10.10.10.2

failover link stateful GigabitEthernet0/2
failover interface ip stateful 10.10.11.1 255.255.255.252 standby 10.10.11.2

failover
```

#结果检查

>* show failover

```
Failover On 
Failover unit Primary
Failover LAN Interface: HA GigabitEthernet0/3 (up)
Unit Poll frequency 1 seconds, holdtime 15 seconds
Interface Poll frequency 5 seconds, holdtime 25 seconds
Interface Policy 1
Monitored Interfaces 3 of 250 maximum
Version: Ours 8.2(1), Mate 8.2(1)
Last Failover at: 03:45:17 HKST Dec 7 2015
        This host: Primary - Active 
                Active time: 98922458 (sec)
                slot 0: ASA5520 hw/sw rev (2.0/8.2(1)) status (Up Sys)
                  Interface outside (192.168.2.226): Normal (Waiting)
                  Interface inside (192.168.100.1): Normal (Waiting)
                  Interface management (0.0.0.0): Link Down (Waiting)
                slot 1: empty
        Other host: Secondary - Standby Ready 
                Active time: 539 (sec)
                slot 0: ASA5520 hw/sw rev (2.0/8.2(1)) status (Up Sys)
                  Interface outside (192.168.2.241): Normal (Waiting)
                  Interface inside (192.168.100.4): Normal (Waiting)
                  Interface management (0.0.0.0): Link Down (Waiting)
                slot 1: empty

Stateful Failover Logical Update Statistics
        Link : stateful GigabitEthernet0/2 (up)
        Stateful Obj    xmit       xerr       rcv        rerr      
        General         19566      0          19         0         
        sys cmd         19         0          19         0         
        up time         0          0          0          0         
        RPC services    0          0          0          0         
        TCP conn        18563      0          0          0         
        UDP conn        699        0          0          0         
        ARP tbl         279        0          0          0         
        Xlate_Timeout   0          0          0          0         
        VPN IKE upd     2          0          0          0         
        VPN IPSEC upd   4          0          0          0         
        VPN CTCP upd    0          0          0          0         
        VPN SDI upd     0          0          0          0         
        VPN DHCP upd    0          0          0          0         
        SIP Session     0          0          0          0         

        Logical Update Queue Information
                        Cur     Max     Total
        Recv Q:         0       18      154
        Xmit Q:         0       1024    22916
```

