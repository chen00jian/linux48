---
title: kube-proxy使用IPVS替代iptables
date: 2019-11-01
tags:
- ipvs
- kube-proxy
- kubernetes 
categories:
 - Container
---


1. 为什么要使用IPVS

从k8s的1.8版本开始，kube-proxy引入了IPVS模式，IPVS模式与iptables同样基于Netfilter，但是采用的hash表，因此当service数量达到一定规模时，hash查表的速度优势就会显现出来，从而提高service的服务性能。

2. 具体步骤

```bash
# 开启内核参数
cat >> /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF


# 开启ipvs支持
yum -y install ipvsadm  ipset

# 永久生效
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

sysctl -p
```

配置kube-proxy,增加标黑色两行，具体参数说明见官网

```bash {6,7}
[root@k8s-node-1 ~]# cat /k8s/kubernetes/cfg/kube-proxy
KUBE_PROXY_OPTS="--logtostderr=true \
--v=4 \
--hostname-override=k8s-node-1 \
--cluster-cidr=10.254.0.0/16 \
--proxy-mode=ipvs  \
--masquerade-all=true \
--kubeconfig=/k8s/kubernetes/cfg/kube-proxy.kubeconfig"

[root@k8s-node-1 ~]# 
```

重启kube-proxy

```bash
systemctl daemon-reload
systemctl restart kube-proxy
systemctl status kube-proxy
```

还需重启

>* CNI网络组件(calico/Flannel)
>* coredns
>* metrics-server
>* nginx-ingress

测试是否生效

``ipvsadm -Ln``



参考

https://www.jianshu.com/p/9b4b700c7765

https://segmentfault.com/a/1190000016333317

