---
title: 思科静态浮动路由配置
date: 2012-03-07
tags:
- cisco
categories:
 - System
---




:blush:


大概说一下浮动路由在网络中的作用主要提供路由备份。保证网络中主链路失效的情况下，提供备份路由实现链路冗余备份。

实验要求  
更具下图分别对R1和R2接口进行配置，s0/0链路配置为静态浮动路由，f0/0链路配置为RIP主路由。但f0/0主链路出现故障时路由器自动切换备用线路。

```bash
R1#conf t  
R1(config)#interface s0/0/0  
R1(config-if)#ip add 172.168.1.1 255.255.255.0  
R1(config-if)#clock rate 128000  
R1(config-if)#no shut  
R1(config-if)#exit  
R1(config)#interface f0/0  
R1(config-if)#ip add 172.168.2.1 255.255.255.0  
R1(config-if)#no shut  
R1(config-if)#exit  
R1(config)#interface loop 0  
R1(config-if)#ip add 1.1.1.1 255.255.255.0  
R1(config-if)#no shut  
R1(config-if)#exit  
R2#conf t  
R2(config)#interface s0/0/0  
R2(config-if)#ip add 172.168.1.2 255.255.255.0  
R2(config-if)#clock rate 128000  
R2(config-if)#no shut  
R2(config-if)#exit  
R2(config)#interface f0/0  
R2(config-if)#ip add 172.168.2.2 255.255.255.0  
R2(config-if)#no shut  
R2(config-if)#exit  
R2(config)#interface loop 0  
R2(config-if)#ip add 2.2.2.2 255.255.255.0  
R2(config-if)#no shut  
R2(config-if)#exit  
```

配置静态浮动路由，修改静态路由的管理距离为125，使路由器选则路由时优先选择RIP。 

```bash 
R1(config)# ip route 2.2.2.0 255.255.255.0 172.168.1.2 125  
R1(config)# router rip  
R1(config-router)# version 2  
R1(config-router)# no auto-summary  
R1(config-router)# network 1.0.0.0  
R1(config-router)# network 172.168.2.0  
R1(config-router)# exit  
R2(config)# ip route 1.1.1.0 255.255.255.0 172.168.1.1 125  
R2(config)# router rip  
R2(config-router)# version 2  
R2(config-router)# no auto-summary  
R2(config-router)# network 1.0.0.0  
R2(config-router)# network 172.168.2.0  
R2(config-router)# exit  
R2(config)# exit  
R2#show ip route  
Codes: C – connected, S – static, I – IGRP, R – RIP, M – mobile, B – BGP  
D – EIGRP, EX – EIGRP external, O – OSPF, IA – OSPF inter area  
N1 – OSPF NSSA external type 1, N2 – OSPF NSSA external type 2  
E1 – OSPF external type 1, E2 – OSPF external type 2, E – EGP  
i – IS-IS, L1 – IS-IS level-1, L2 – IS-IS level-2, ia – IS-IS inter area  
* – candidate default, U – per-user static route, o – ODR  
P – periodic downloaded static route  
Gateway of last resort is not set  
```

路由器将去往1.1.1.0网段的RIP路由写入路由表，因为RIP的管理距离为120，小于静态路由管理距离优先，所有静态路由处于备份状态。 
```bash 
1.0.0.0/24 is subnetted, 1 subnets  
R 1.1.1.0 [120/1] via 172.168.2.1, 00:00:10, FastEthernet0/0  
[120/1] via 172.168.1.1, 00:00:10, Serial0/0/0  
2.0.0.0/24 is subnetted, 1 subnets  
C 2.2.2.0 is directly connected, Loopback0  
172.168.0.0/24 is subnetted, 2 subnets  
C 172.168.1.0 is directly connected, Serial0/0/0  
C 172.168.2.0 is directly connected, FastEthernet0/0  
```

此时我们将R1路由器的f0/0口关闭，目的是将R2的静态路由激活。  

```bash
R1(config)#interface f0/0  
R1(config-if)#shut  
%LINK-5-CHANGED: Interface FastEthernet0/0, changed state to administratively down  
%LINEPROTO-5-UPDO  
R2#  
%LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/0, changed state to down  
R2#show ip route  
Codes: C – connected, S – static, I – IGRP, R – RIP, M – mobile, B – BGP  
D – EIGRP, EX – EIGRP external, O – OSPF, IA – OSPF inter area  
N1 – OSPF NSSA external type 1, N2 – OSPF NSSA external type 2  
E1 – OSPF external type 1, E2 – OSPF external type 2, E – EGP  
i – IS-IS, L1 – IS-IS level-1, L2 – IS-IS level-2, ia – IS-IS inter area  
* – candidate default, U – per-user static route, o – ODR  
P – periodic downloaded static route  
Gateway of last resort is not set  
```

在R2中重新查看路由表信息，去往1.1.1.0网段的静态路由（备份路由）已经写入到路由表。

```bash  
1.0.0.0/24 is subnetted, 1 subnets  
R 1.1.1.0 [120/1] via 172.168.1.1, 00:00:00, Serial0/0/0  
2.0.0.0/24 is subnetted, 1 subnets  
C 2.2.2.0 is directly connected, Loopback0  
172.168.0.0/24 is subnetted, 1 subnets  
C 172.168.1.0 is directly connected, Serial0/0/0
```
