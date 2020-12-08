---
title: k8s部署mertics-server
date: 2019-11-13
tags:
- mertics-server
- kubernetes
categories:
 - Container
---



集群部署好后，如果我们想知道集群中每个节点及节点上的`pod`资源使用情况，命令行下可以直接使用`kubectl top node/pod`来查看资源使用情况，默认此命令不能正常使用，需要我们部署对应`api`资源才可以使用此命令。从 `Kubernetes 1.8` 开始，资源使用指标（如容器 `CPU` 和内存使用率）通过 `Metrics API` 在 `Kubernetes` 中获取, `metrics-server` 替代了~~heapster~~。`Metrics Server` 实现了`Resource Metrics API`，`Metrics Server` 是集群范围资源使用数据的聚合器。 `Metrics Server` 从每个节点上的 `Kubelet` 公开的 `Summary API` 中采集指标信息。`heapster`从`1.13`版本开始被废弃，官方推荐使用`Metrics Server+Prometheus`方案进行集群监控

**开启`apiserver`聚合服务**

要安装mertics-server必须先开启聚合服务的参数，如果已经添加，请跳过这一步

二进制部署安装，需要手动修改`apiserver`添加开启

kube-apiserver配置文件修改，增加标记黑色的行数

```bash {23,24,25,26,27,28,29,30}
[root@k8s-master 1.8+]# cat /k8s/kubernetes/cfg/kube-apiserver 
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

[root@k8s-master 1.8+]# 
```

**部署metrics-server**

```bash
[root@k8s-master 1.8+]# git clone https://github.com/kubernetes-sigs/metrics-server.git

[root@k8s-master 1.8+]# cd /app/yaml/metrics-server/deploy/1.8+
[root@k8s-master01 metrics]# vim metrics-server-deployment.yaml 
### mertics-server修改启动参数镜像地址，增加command
......
containers:
      - name: metrics-server
        image: registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-server-amd64:v0.3.6
        command:
        - /metrics-server
        - --metric-resolution=30s
        - --kubelet-insecure-tls
        - --kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalDNS,ExternalIP
......
### 创建metrics-server
[root@k8s-master 1.8+]# kubectl  apply -f .
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
serviceaccount/metrics-server created
deployment.extensions/metrics-server created
service/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
[root@k8s-master 1.8+]# 
[root@k8s-master 1.8+]# kubectl get pods -n kube-system |grep metrics-server
metrics-server-599f4f9874-w6vnx         1/1     Running   1          5h39m
[root@k8s-master 1.8+]# 
[root@k8s-master 1.8+]# 
[root@k8s-master 1.8+]# kubectl -n kube-system logs -l k8s-app=metrics-server  -f
I1114 08:49:48.802857       1 serving.go:312] Generated self-signed cert (/tmp/apiserver.crt, /tmp/apiserver.key)
I1114 08:49:49.717666       1 secure_serving.go:116] Serving securely on [::]:4443
```

**`kubectl  top`查看**

```bash
[root@k8s-master 1.8+]# kubectl  top node
NAME         CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k8s-master   94m          2%     5119Mi          66%       
k8s-node-1   108m         2%     4877Mi          63%       
k8s-node-2   75m          1%     3182Mi          41%       
[root@k8s-master 1.8+]# kubectl  top pod
NAME                                    CPU(cores)   MEMORY(bytes)   
app-test-54fb88d9b-2jf6m                0m           2Mi             
nfs-client-provisioner-6f5d588-mq6l2    1m           6Mi             
nfs-web-0                               0m           2Mi             
nfs-web-1                               0m           2Mi             
nginx-6dbd5b5bd-f4fkg                   0m           2Mi             
```

--------

ps

**碰到的问题**


```bash
$ kubectl top pods
Error from server (ServiceUnavailable): the server is currently unable to handle the request (get pods.metrics.k8s.io)

$ kubectl api-resources
error: unable to retrieve the complete list of server APIs: metrics.k8s.io/v1beta1: the server is currently unable to handle the request

$ kubectl get apiservices | grep metrics
v1beta1.metrics.k8s.io                 kube-system/metrics-server   False (FailedDiscoveryCheck)   2m21s


[root@k8s-master yarm]# kubectl get apiservices v1beta1.metrics.k8s.io -o yaml
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  creationTimestamp: "2019-11-13T09:51:00Z"
  name: v1beta1.metrics.k8s.io
  resourceVersion: "5866720"
  selfLink: /apis/apiregistration.k8s.io/v1/apiservices/v1beta1.metrics.k8s.io
  uid: 8132b60e-ef07-4af0-baaf-aaadf355a852
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
    port: 443
  version: v1beta1
  versionPriority: 100
status:
  conditions:
  - lastTransitionTime: "2019-11-13T16:03:47Z"
    message: 'failing or missing response from https://10.152.183.90:443/apis/metrics.k8s.io/v1beta1:
      bad status from https://10.152.183.90:443/apis/metrics.k8s.io/v1beta1: 403'
    reason: FailedDiscoveryCheck
    status: "False"
    type: Available


[root@k8s-master 1.8+]# kubectl -n kube-system logs -l k8s-app=metrics-server  -f
W1113 09:59:50.576292       1 x509.go:172] x509: subject with cn=system:kube-proxy is not in the allowed list: [aggregator]
W1113 10:00:01.714599       1 x509.go:172] x509: subject with cn=system:kube-proxy is not in the allowed list: [aggregator]
W1113 10:00:01.714629       1 x509.go:172] x509: subject with cn=system:kube-proxy is not in the allowed list: [aggregator]
W1113 10:00:01.714657       1 x509.go:172] x509: subject with cn=system:kube-proxy is not in the allowed list: [aggregator]
W1113 10:00:01.714693       1 x509.go:172] x509: subject with cn=system:kube-proxy is not in the allowed list: [aggregator]
```

**原因**

该问题与`kube-apiservrer`的`--requestheader-allowed-names`配置项有关。

:::tip
--requestheader-allowed-names strings

List of client certificate common names to allow to provide usernames in headers specified by --requestheader-username-headers. If empty, any client certificate validated by the authorities in --requestheader-client-ca-file is allowed.
:::

原错误配置为`--requestheader-allowed-names=aggregator`。也就是说只有以`aggregator`开头的`Role`才能通过认证，导致各个节点（角色名为`cn=system:node:[节点IP]`）被决绝访问。

另外，`kube-aggregator`访问`kubelet`所用证书原为`aggregator`，有可能会因权限不够而被拒绝。

```bash
  - --proxy-client-cert-file=/var/lib/kubernetes/aggregator.pem
  - --proxy-client-key-file=/var/lib/kubernetes/aggregator-key.pem
```

**解决方案**

首先，将`--requestheader-allowed-names=aggregator`配置改为：`--requestheader-allowed-names=`


即不验证证书中角色名字，直接验证角色权限。

其次，将访问kubelet所用的证书改为admin证书，让kube-aggregator获取最高权限，保证能够正常访问kubelet。

```bash
  --proxy-client-cert-file=/k8s/kubernetes/ssl/kube-proxy.pem \
  --proxy-client-key-file=/k8s/kubernetes/ssl/kube-proxy-key.pem \
```
至此，上述log消失。问题解决。


参考

https://www.cnblogs.com/tchua/p/10855001.html

http://blog.allen-mo.com/2018/08/26/kubernetes_cluster_troubleshooting/
