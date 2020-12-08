---
title: kubernetes二进制最新版安装
date: 2019-09-11
tags:
- kubernetes
- docker
categories:
 - Container
---

::: tip
本文将每个组件安装配置都细化，适合初学者安装，具有一定参考价值
:::

<!-- more -->


## 操作系统

```bash
[root@localhost ~]# uname -a
Linux localhost.localdomain 3.10.0-514.6.1.el7.x86_64 #1 SMP Wed Jan 18 13:06:36 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
[root@localhost ~]# cat /etc/redhat-release
CentOS Linux release 7.3.1611 (Core)
```

## 节点分配

| 节点及功能    | 主机名   |  ip  |
| :-----: | :-----:  | :----:  |
| kube-apiserver、kube-controller-manager、kube-scheduler、docker、etcd、registry、flannel  |  K8s-master    |  10.255.0.170     |
| kubelet、kubeproxy、docker、flannel   |  K8s-node-1   |  10.255.0.171   |
| kubelet、kubeproxy、docker、flannel   |  K8s-node-2   |  10.255.0.172   |

## 基础配置

:::tip
master和node都要设置
:::

```bash
# hostname
hostnamectl --static set-hostname  k8s-master
hostnamectl --static set-hostname  k8s-node-1
hostnamectl --static set-hostname  k8s-node-2

# 关闭 防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭 SeLinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

# 关闭 swap
swapoff -a
yes | cp /etc/fstab /etc/fstab_bak
cat /etc/fstab_bak |grep -v swap > /etc/fstab

# 修改 /etc/sysctl.conf
# 如果有配置，则修改
sed -i "s#^net.ipv4.ip_forward.*#net.ipv4.ip_forward=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-ip6tables.*#net.bridge.bridge-nf-call-ip6tables=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-iptables.*#net.bridge.bridge-nf-call-iptables=1#g"  /etc/sysctl.conf
# 可能没有，追加
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
# 执行命令以应用
sysctl -p


# hosts
10.255.0.170    k8s-master
10.255.0.170    etcd
10.255.0.170    registry
10.255.0.171    k8s-node-1
10.255.0.172    k8s-node-2
```

## Docker环境安装

:::tip
master node都要安装docker
:::

```bash
yum -y install yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum list docker-ce --showduplicates | sort -r
yum install docker-ce -y
systemctl enable docker
systemctl start docker
cat /etc/docker/daemon.json
{ "insecure-registries":["registry:5000"] }
docker version
```

## 下载软件包

:::tip
使用海外服务器下载快，下载完成传至服务器
:::

```bash
[root@hk ~]# cat wget.sh 
# https://github.com/minminmsn/k8s1.13/tree/master/kubernetes

wget https://dl.k8s.io/v1.15.0/kubernetes-client-linux-amd64.tar.gz
wget https://dl.k8s.io/v1.15.0/kubernetes-server-linux-amd64.tar.gz
wget https://dl.k8s.io/v1.15.0/kubernetes-node-linux-amd64.tar.gz
wget https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz
wget https://github.com/coreos/flannel/releases/download/v0.11.0/flannel-v0.11.0-linux-amd64.tar.gz
```


## 创建etcd证书

:::tip
在master创建
:::

### cfssl安装

```bash
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
```

### 创建etcd证书

```bash
mkdir /k8s/etcd/{bin,cfg,ssl} -p
mkdir /k8s/kubernetes/{bin,cfg,ssl} -p
cd /k8s/etcd/ssl/

# etcd ca配置

cat << EOF | tee ca-config.json
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "etcd": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF


# etcd ca证书

cat << EOF | tee ca-csr.json
{
    "CN": "etcd CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing"
        }
    ]
}
EOF

# etcd server证书

cat << EOF | tee server-csr.json
{
    "CN": "etcd",
    "hosts": [
    "k8s-master",
    "k8s-node-1",
    "k8s-node-2"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing"
        }
    ]
}
EOF

# 生成etcd ca证书和私钥 初始化ca
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# 生成server证书

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd server-csr.json | cfssljson -bare server
```


## 部署etcd

:::tip
在master部署
:::


```bash
# 解压缩

tar -xvf etcd-v3.3.13-linux-amd64.tar.gz 
cd etcd-v3.3.13-linux-amd64
cp etcd etcdctl /k8s/etcd/bin/

# 配置etcd主配置文件

vim /k8s/etcd/cfg/etcd.conf
#[Member]
ETCD_NAME="etcd01"
ETCD_DATA_DIR="/data1/etcd"
ETCD_LISTEN_PEER_URLS="https://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="https://0.0.0.0:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://k8s-master:2380"
ETCD_ADVERTISE_CLIENT_URLS="https://k8s-master:2379"
ETCD_INITIAL_CLUSTER="etcd01=https://k8s-master:2380,etcd02=https://k8s-node-1:2380,etcd03=https://k8s-node-2:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"

#[Security]
ETCD_CERT_FILE="/k8s/etcd/ssl/server.pem"
ETCD_KEY_FILE="/k8s/etcd/ssl/server-key.pem"
ETCD_TRUSTED_CA_FILE="/k8s/etcd/ssl/ca.pem"
ETCD_CLIENT_CERT_AUTH="true"
ETCD_PEER_CERT_FILE="/k8s/etcd/ssl/server.pem"
ETCD_PEER_KEY_FILE="/k8s/etcd/ssl/server-key.pem"
ETCD_PEER_TRUSTED_CA_FILE="/k8s/etcd/ssl/ca.pem"
ETCD_PEER_CLIENT_CERT_AUTH="true"


# 配置etcd启动文件

mkdir -p /data1/etcd

vim /usr/lib/systemd/system/etcd.service
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=/data1/etcd/
EnvironmentFile=-/k8s/etcd/cfg/etcd.conf
# set GOMAXPROCS to number of processors
ExecStart=/bin/bash -c "GOMAXPROCS=$(nproc) /k8s/etcd/bin/etcd --name=\"${ETCD_NAME}\" --data-dir=\"${ETCD_DATA_DIR}\" --listen-client-urls=\"${ETCD_LISTEN_CLIENT_URLS}\" --listen-peer-urls=\"${ETCD_LISTEN_PEER_URLS}\" --advertise-client-urls=\"${ETCD_ADVERTISE_CLIENT_URLS}\" --initial-cluster-token=\"${ETCD_INITIAL_CLUSTER_TOKEN}\" --initial-cluster=\"${ETCD_INITIAL_CLUSTER}\" --initial-cluster-state=\"${ETCD_INITIAL_CLUSTER_STATE}\" --cert-file=\"${ETCD_CERT_FILE}\" --key-file=\"${ETCD_KEY_FILE}\" --trusted-ca-file=\"${ETCD_TRUSTED_CA_FILE}\" --client-cert-auth=\"${ETCD_CLIENT_CERT_AUTH}\" --peer-cert-file=\"${ETCD_PEER_CERT_FILE}\" --peer-key-file=\"${ETCD_PEER_KEY_FILE}\" --peer-trusted-ca-file=\"${ETCD_PEER_TRUSTED_CA_FILE}\" --peer-client-cert-auth=\"${ETCD_PEER_CLIENT_CERT_AUTH}\""
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

# 启动etcd

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
```

:::tip
两台`node`同样安装`etcd`并配置，注意修改相关参数

注意启动前把`master`的证书`scp`到`node-1 node-2`并且`etcd02、etcd03`同样安装`etcd`并配置

`scp master:/k8s/etcd/ssl/*  node-*:/k8s/etcd/ssl`

只有当三个节点的`etcd`都执行启动命令,`etcd`服务方可成功启动
:::




etcd服务健康检查

```bash
[root@k8s-master ssl]# /k8s/etcd/bin/etcdctl --ca-file=/k8s/etcd/ssl/ca.pem --cert-file=/k8s/etcd/ssl/server.pem --key-file=/k8s/etcd/ssl/server-key.pem --endpoints="https://k8s-master:2379,https://k8s-node-1:2379,https://k8s-node-2:2379" cluster-health
member 46252917a5ec862b is healthy: got healthy result from https://k8s-node-2:2379
member 479af84c2da5bdfb is healthy: got healthy result from https://k8s-node-1:2379
member c4a8f6a83e833345 is healthy: got healthy result from https://k8s-master:2379
cluster is healthy
[root@k8s-master ssl]#
```


## 创建kubernets相关证书

:::tip
在master创建
:::

```bash
# 制作kubernetes ca证书

cd /k8s/kubernetes/ssl
cat << EOF | tee ca-config.json
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
         "expiry": "87600h",
         "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ]
      }
    }
  }
}
EOF


cat << EOF | tee ca-csr.json
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF


cfssl gencert -initca ca-csr.json | cfssljson -bare ca -


# 制作apiserver证书

cat << EOF | tee server-csr.json
{
    "CN": "kubernetes",
    "hosts": [
      "10.254.0.1",
      "127.0.0.1",
      "k8s-master",
      "k8s-node-1",
      "k8s-node-2",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "Beijing",
            "ST": "Beijing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes server-csr.json | cfssljson -bare server


# 制作kube-proxy证书

cat << EOF | tee kube-proxy-csr.json
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "Beijing",
      "ST": "Beijing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF


cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy
```

## 部署kubernetes server

:::tip
在master部署
:::

```bash
# 解压缩文件
tar -zxvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin/
cp kube-scheduler kube-apiserver kube-controller-manager kubectl /k8s/kubernetes/bin/


# 部署kube-apiserver组件 创建TLS Bootstrapping Token
head -c 16 /dev/urandom | od -An -t x | tr -d ' '
e2c6f99a270a1766851e6516eb3e9941
 
vim /k8s/kubernetes/cfg/token.csv
e2c6f99a270a1766851e6516eb3e9941,kubelet-bootstrap,10001,"system:kubelet-bootstrap"


# 创建Apiserver配置文件

vim /k8s/kubernetes/cfg/kube-apiserver 
KUBE_APISERVER_OPTS="--logtostderr=true \
--v=4 \
--etcd-servers=https://k8s-master:2379,https://k8s-node-1:2379,https://k8s-node-2:2379 \
--bind-address=0.0.0.0 \
--insecure-bind-address=0.0.0.0 \
--secure-port=6443 \
--advertise-address=0.0.0.0 \
--allow-privileged=true \
--service-cluster-ip-range=10.254.0.0/16 \
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,NodeRestriction \
--authorization-mode=RBAC,Node \
--enable-bootstrap-token-auth \
--token-auth-file=/k8s/kubernetes/cfg/token.csv \
--service-node-port-range=30000-50000 \
--tls-cert-file=/k8s/kubernetes/ssl/server.pem  \
--tls-private-key-file=/k8s/kubernetes/ssl/server-key.pem \
--client-ca-file=/k8s/kubernetes/ssl/ca.pem \
--service-account-key-file=/k8s/kubernetes/ssl/ca-key.pem \
--etcd-cafile=/k8s/etcd/ssl/ca.pem \
--etcd-certfile=/k8s/etcd/ssl/server.pem \
--etcd-keyfile=/k8s/etcd/ssl/server-key.pem \
--runtime-config=api/all=true \
--proxy-client-cert-file=/k8s/kubernetes/ssl/kube-proxy.pem \
--proxy-client-key-file=/k8s/kubernetes/ssl/kube-proxy-key.pem \
--requestheader-client-ca-file=/k8s/kubernetes/ssl/ca.pem \
--requestheader-allowed-names= \
--requestheader-extra-headers-prefix=X-Remote-Extra- \
--requestheader-group-headers=X-Remote-Group \
--requestheader-username-headers=X-Remote-User"


# 创建apiserver systemd文件

vim /usr/lib/systemd/system/kube-apiserver.service 

[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes
 
[Service]
EnvironmentFile=-/k8s/kubernetes/cfg/kube-apiserver
ExecStart=/k8s/kubernetes/bin/kube-apiserver $KUBE_APISERVER_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target


# 启动apiserver服务

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver
systemctl status kube-apiserver
ps -ef |grep kube-apiserver
netstat -tulpn |grep kube-apiserve


# 部署kube-scheduler组件 创建kube-scheduler配置文件

vim  /k8s/kubernetes/cfg/kube-scheduler
KUBE_SCHEDULER_OPTS="--logtostderr=true --v=4 --master=127.0.0.1:8080 --leader-elect"


# 创建kube-scheduler systemd文件

vim /usr/lib/systemd/system/kube-scheduler.service 
 
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes
 
[Service]
EnvironmentFile=-/k8s/kubernetes/cfg/kube-scheduler
ExecStart=/k8s/kubernetes/bin/kube-scheduler $KUBE_SCHEDULER_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target


# 启动kube-scheduler服务

systemctl daemon-reload
systemctl enable kube-scheduler.service
systemctl restart kube-scheduler.service
systemctl status kube-scheduler.service

# 部署kube-controller-manager组件 创建kube-controller-manager配置文件

vim /k8s/kubernetes/cfg/kube-controller-manager
KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=true \
--v=4 \
--master=127.0.0.1:8080 \
--leader-elect=true \
--address=127.0.0.1 \
--service-cluster-ip-range=10.254.0.0/16 \
--cluster-name=kubernetes \
--cluster-signing-cert-file=/k8s/kubernetes/ssl/ca.pem \
--cluster-signing-key-file=/k8s/kubernetes/ssl/ca-key.pem  \
--root-ca-file=/k8s/kubernetes/ssl/ca.pem \
--service-account-private-key-file=/k8s/kubernetes/ssl/ca-key.pem"

# 创建kube-controller-manager systemd文件

vim /usr/lib/systemd/system/kube-controller-manager.service 
 
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes
 
[Service]
EnvironmentFile=-/k8s/kubernetes/cfg/kube-controller-manager
ExecStart=/k8s/kubernetes/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target


# 启动kube-controller-manager服务

systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl restart kube-controller-manager
systemctl status kube-controller-manager
```

验证kubeserver服务

```bash
# 设置环境变量

vim /etc/profile
PATH=/k8s/kubernetes/bin:$PATH
source /etc/profile

# 查看master服务状态

[root@k8s-master app]# kubectl get cs,nodes
NAME                                 STATUS    MESSAGE             ERROR
componentstatus/controller-manager   Healthy   ok                  
componentstatus/scheduler            Healthy   ok                  
componentstatus/etcd-0               Healthy   {"health":"true"}   
componentstatus/etcd-1               Healthy   {"health":"true"}   
componentstatus/etcd-2               Healthy   {"health":"true"}   
```

## 部署kubelet组件

:::tip
在node部署
:::

```bash {17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66}
mkdir /k8s/etcd/{bin,cfg,ssl} -p
mkdir /k8s/kubernetes/{bin,cfg,ssl} -p

# 安装二进制文件

tar zxvf kubernetes-node-linux-amd64.tar.gz
cd kubernetes/node/bin/
cp kube-proxy kubelet kubectl /k8s/kubernetes/bin/


# 复制master相关证书到node节点

scp -r master:/k8s/kubernetes/ssl/*  node-*:/k8s/kubernetes/ssl

# 创建kubelet bootstrap kubeconfig文件 通过脚本实现

[root@k8s-node-1 ~]# cat /k8s/kubernetes/cfg/environment.sh
#!/bin/bash
#创建kubelet bootstrapping kubeconfig  前面生成的TOKEN
BOOTSTRAP_TOKEN=8be6eedaf2f542f6b2c1b26e56777b87
KUBE_APISERVER="https://k8s-master:6443"
#设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/k8s/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig
 
#设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig
 
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig
 
# 设置默认上下文
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig
 
#----------------------
 
# 创建kube-proxy kubeconfig文件
 
kubectl config set-cluster kubernetes \
  --certificate-authority=/k8s/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig
 
kubectl config set-credentials kube-proxy \
  --client-certificate=/k8s/kubernetes/ssl/kube-proxy.pem \
  --client-key=/k8s/kubernetes/ssl/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
 
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
 
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

[root@k8s-node-1 ~]# 



# 设置环境变量

vim /etc/profile
PATH=/k8s/kubernetes/bin:$PATH
source /etc/profile

cd /k8s/kubernetes/cfg
sh environment.sh

[root@k8s-node-1 cfg]# sh environment.sh 
Cluster "kubernetes" set.
User "kubelet-bootstrap" set.
Context "default" created.
Switched to context "default".
Cluster "kubernetes" set.
User "kube-proxy" set.
Context "default" created.
Switched to context "default".
[root@k8s-node-1 cfg]# 

[root@k8s-node-1 cfg]# ls
bootstrap.kubeconfig  environment.sh  kube-proxy.kubeconfig



# 创建kubelet参数配置模板文件

vim /k8s/kubernetes/cfg/kubelet.config
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: 0.0.0.0
port: 10250
readOnlyPort: 10255
cgroupDriver: cgroupfs
clusterDNS: ["10.254.0.100"]
clusterDomain: cluster.local
failSwapOn: false
authentication:
  anonymous:
    enabled: true

# 创建kubelet配置文件
vim /k8s/kubernetes/cfg/kubelet
 
KUBELET_OPTS="--logtostderr=true \
--v=4 \
--hostname-override=k8s-node-1 \
--kubeconfig=/k8s/kubernetes/cfg/kubelet.kubeconfig \
--bootstrap-kubeconfig=/k8s/kubernetes/cfg/bootstrap.kubeconfig \
--config=/k8s/kubernetes/cfg/kubelet.config \
--cert-dir=/k8s/kubernetes/ssl \
--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google-containers/pause-amd64:3.0"

# 创建kubelet systemd文件

vim /usr/lib/systemd/system/kubelet.service
 
[Unit]
Description=Kubernetes Kubelet
After=docker.service
Requires=docker.service
 
[Service]
EnvironmentFile=/k8s/kubernetes/cfg/kubelet
ExecStart=/k8s/kubernetes/bin/kubelet $KUBELET_OPTS
Restart=on-failure
KillMode=process
 
[Install]
WantedBy=multi-user.target

# 在master上操作将kubelet-bootstrap用户绑定到系统集群角色

kubectl create clusterrolebinding kubelet-bootstrap \
  --clusterrole=system:node-bootstrapper \
  --user=kubelet-bootstrap


[root@k8s-master ssl]# kubectl create clusterrolebinding kubelet-bootstrap \
>   --clusterrole=system:node-bootstrapper \
>   --user=kubelet-bootstrap
clusterrolebinding.rbac.authorization.k8s.io/kubelet-bootstrap created


# 启动kubelet服务 
systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
systemctl status kubelet


# 在Master上操作 接受kubelet CSR请求
# 查看此时为Pending状态
[root@k8s-master ssl]# kubectl get csr
NAME                                                   AGE   REQUESTOR           CONDITION
node-csr-fjtFx8dxrIUY1rXsQwJDHluXZ_GHTN4iUvWzr3D8ugs   46s   kubelet-bootstrap   Pending
node-csr-vOKS07ZEPsuTJSznctfsj2B849cTilaS_xgmlQXn9NU   43s   kubelet-bootstrap   Pending

# 接受node
[root@k8s-master ssl]# kubectl certificate approve node-csr-fjtFx8dxrIUY1rXsQwJDHluXZ_GHTN4iUvWzr3D8ugs
certificatesigningrequest.certificates.k8s.io/node-csr-fjtFx8dxrIUY1rXsQwJDHluXZ_GHTN4iUvWzr3D8ugs approved
[root@k8s-master ssl]# kubectl certificate approve node-csr-vOKS07ZEPsuTJSznctfsj2B849cTilaS_xgmlQXn9NU
certificatesigningrequest.certificates.k8s.io/node-csr-vOKS07ZEPsuTJSznctfsj2B849cTilaS_xgmlQXn9NU approved
[root@k8s-master ssl]# 

# 再查看CSR此时为Approved状态
[root@k8s-master ssl]# kubectl get csr
NAME                                                   AGE   REQUESTOR           CONDITION
node-csr-fjtFx8dxrIUY1rXsQwJDHluXZ_GHTN4iUvWzr3D8ugs   88s   kubelet-bootstrap   Approved,Issued
node-csr-vOKS07ZEPsuTJSznctfsj2B849cTilaS_xgmlQXn9NU   85s   kubelet-bootstrap   Approved,Issued
```

## 部署kube-proxy组件

:::tip
在node部署
:::

`kube-proxy`运行在所有`node`节点上，它监听`apiserver`中`service`和`Endpoint`的变化情况，创建路由规则来进行服务负载均衡。


```bash
# 创建 kube-proxy 配置文件

vim /k8s/kubernetes/cfg/kube-proxy
KUBE_PROXY_OPTS="--logtostderr=true \
--v=4 \
--hostname-override=k8s-node-1 \
--cluster-cidr=10.254.0.0/16 \
--kubeconfig=/k8s/kubernetes/cfg/kube-proxy.kubeconfig"

# 创建kube-proxy systemd文件

vim /usr/lib/systemd/system/kube-proxy.service
 
[Unit]
Description=Kubernetes Proxy
After=network.target
 
[Service]
EnvironmentFile=-/k8s/kubernetes/cfg/kube-proxy
ExecStart=/k8s/kubernetes/bin/kube-proxy $KUBE_PROXY_OPTS
Restart=on-failure
 
[Install]
WantedBy=multi-user.target


# 启动kube-proxy服务 
systemctl daemon-reload
systemctl enable kube-proxy
systemctl start kube-proxy
systemctl status  kube-proxy
```

## master查看集群状态

```bash
[root@k8s-master ~]# kubectl get nodes
NAME         STATUS   ROLES    AGE   VERSION
k8s-node-1   Ready    <none>   20d   v1.15.0
k8s-node-2   Ready    <none>   20d   v1.15.0
```



## 部署flanneld组件

:::tip
master node都必须安装
:::

:::tip
默认没有`flanneld`网络，`Node`节点间的`pod`不能通信，只能`Node`内通信

为了部署步骤简洁明了，故`flanneld`放在后面安装

`flannel`服务需要先于`docker`启动

`flannel`服务启动时主要做了以下几步的工作： 

从`etcd`中获取`network`的配置信息划分`subnet`，并在`etcd`中进行注册将子网信息记录到`/run/flannel/subnet.env`中
:::

```bash
# etcd注册网段 master node都执行

[root@k8s-master ~]# /k8s/etcd/bin/etcdctl --ca-file=/k8s/etcd/ssl/ca.pem --cert-file=/k8s/etcd/ssl/server.pem --key-file=/k8s/etcd/ssl/server-key.pem --endpoints="https://k8s-master:2379,https://k8s-node-1:2379,https://k8s-node-2:2379"  set /k8s/network/config  '{ "Network": "10.254.0.0/16", "Backend": {"Type": "vxlan"}}'
{ "Network": "10.254.0.0/16", "Backend": {"Type": "vxlan"}}


# flannel解压安装

tar -xvf flannel-v0.11.0-linux-amd64.tar.gz
mv flanneld mk-docker-opts.sh /k8s/kubernetes/bin/

# 配置flanneld

vim /k8s/kubernetes/cfg/flanneld
FLANNEL_OPTIONS="--etcd-endpoints=https://k8s-master:2379,https://k8s-node-1:2379,https://k8s-node-2:2379 -etcd-cafile=/k8s/etcd/ssl/ca.pem -etcd-certfile=/k8s/etcd/ssl/server.pem -etcd-keyfile=/k8s/etcd/ssl/server-key.pem -etcd-prefix=/k8s/network"

# 创建flanneld systemd文件

vim /usr/lib/systemd/system/flanneld.service
[Unit]
Description=Flanneld overlay address etcd agent
After=network-online.target network.target
Before=docker.service
 
[Service]
Type=notify
EnvironmentFile=/k8s/kubernetes/cfg/flanneld
ExecStart=/k8s/kubernetes/bin/flanneld --ip-masq $FLANNEL_OPTIONS
ExecStartPost=/k8s/kubernetes/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env
Restart=on-failure
 
[Install]
WantedBy=multi-user.target

############注意############
# mk-docker-opts.sh 脚本将分配给 flanneld 的 Pod 子网网段信息写入 /run/flannel/docker 文件
# 后续 docker 启动时使用这个文件中的环境变量配置 docker0 网桥
# flanneld 使用系统缺省路由所在的接口与其它节点通信
# 对于有多个网络接口（如内网和公网）的节点，可以用 -iface 参数指定通信接口; flanneld 运行时需要 root 权限
# node配置Docker启动指定子网 修改EnvironmentFile=/run/flannel/subnet.env，ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS即可
###########################


# 修改docker systemd文件

:> /usr/lib/systemd/system/docker.service
vim /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target
 
[Service]
Type=notify
EnvironmentFile=/run/flannel/subnet.env
ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
 
[Install]
WantedBy=multi-user.target

# 启动flanneld服务
# 注意启动flannel前要关闭docker及相关的kubelet这样flannel才会覆盖docker0网桥

systemctl daemon-reload
systemctl stop docker
systemctl start flanneld
systemctl enable flanneld
systemctl start docker

systemctl restart kubelet
systemctl restart kube-proxy

# 验证服务

[root@k8s-node-1 kubernetes-1.15]# cat /run/flannel/subnet.env 
DOCKER_OPT_BIP="--bip=10.254.36.1/24"
DOCKER_OPT_IPMASQ="--ip-masq=false"
DOCKER_OPT_MTU="--mtu=1450"
DOCKER_NETWORK_OPTIONS=" --bip=10.254.36.1/24 --ip-masq=false --mtu=1450"

[root@k8s-node-1 kubernetes-1.15]# ifconfig  发现flannel网卡
```

## 部署dns组件

```bash
#kube-dns
https://linux48.com/container/2019-07-12-k8s.html#%E5%AE%89%E8%A3%85kube-dns

#coredns(推荐)
https://linux48.com/container/2019-11-21-k8s-dns.html

```

## 部署官方dashboard

推荐安装kubesphere

https://linux48.com/container/2019-11-20-install-kubesphere-mini.html

```bash
[root@k8s-master kubernetes-1.15]# kubectl create clusterrolebinding system:anonymous   --clusterrole=cluster-admin   --user=system:anonymous
clusterrolebinding.rbac.authorization.k8s.io/system:anonymous created


cd /k8s/
mkdir certs
openssl req -nodes -newkey rsa:2048 -keyout certs/dashboard.key -out certs/dashboard.csr -subj "/C=/ST=/L=/O=/OU=/CN=kubernetes-dashboard"
openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt
kubectl create secret generic kubernetes-dashboard-certs --from-file=certs -n kube-system
wget https://raw.githubusercontent.com/koy1619/k8s_yaml/master/kubernetes-dashboard/kubernetes-dashboard.yaml
kubectl create -f kubernetes-dashboard.yaml
wget https://raw.githubusercontent.com/koy1619/k8s_yaml/master/kubernetes-dashboard/admin-token.yaml
kubectl create -f admin-token.yaml
kubectl get svc -n kube-system

#访问dashboard
https://node*:30443

#get_token
kubectl describe secret/$(kubectl get secret -nkube-system |grep admin-token|awk '{print $1}') -nkube-system


#Kubernetes dashboard集成heapster

wget https://raw.githubusercontent.com/kubernetes-retired/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
wget https://raw.githubusercontent.com/kubernetes-retired/heapster/master/deploy/kube-config/influxdb/heapster.yaml

wget https://raw.githubusercontent.com/kubernetes-retired/heapster/master/deploy/kube-config/influxdb/grafana.yaml
wget https://raw.githubusercontent.com/kubernetes-retired/heapster/master/deploy/kube-config/influxdb/influxdb.yaml

#同前面一样先解决images问题

#只修改image,其他文件不用更改

kubectl create -f heapster-rbac.yaml
kubectl create -f heapster.yaml

kubectl top node
kubectl top pod

#提示：如果我们不用grafana界面和influxdb，只是为了支持dashboard我们可以只安装rbac和heapster，后面我也没有使用ui界面，所以后面的grafana和influxdb我们可以不安装执行哦~

#打开kubernetes-dashboard的web界面workload页面显示监控图形

#参考：https://k.i4t.com/kubernetes_heapster.html
```

:::tip
从 Kubernetes 1.8 开始，资源使用指标（如容器 CPU 和内存使用率）通过 Metrics API 在 Kubernetes 中获取, metrics-server 替代了heapster

参见

https://linux48.com/container/2019-11-13-metrics-server.html
:::

## ingress服务暴露

::: tip
参见

https://linux48.com/container/2019-09-13-traefik.html
:::

## LAST

::: warning 注意
**k8s整个生态组件有一定的依赖关系**

etcd: 无依赖

flanneld: 依赖etcd(网络组件可选)

docker: 依赖flanneld

kube-apiserver: 依赖etcd

kube-controller-manager

kube-scheduler

kubelet: 依赖etcd和k8s-master

kube-proxy

**[通俗易懂理解Kubernetes核心组件及原理][1]**
:::

  [1]: https://mp.weixin.qq.com/s/NU6Dsq83jebTDGYSADONZQ
