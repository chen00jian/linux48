---
title: kubesphere-minimal-安装
date: 2019-11-20
tags:
- kubesphere
- kubernetes
categories:
 - Container
---

我的论坛ID

https://kubesphere.com.cn/forum/u/koy1619

## 前提条件

:::tip
`Kubernetes`版本： `1.13.0` ≤ `K8s version` < `1.16`；

`Helm`，版本 = `v2.15.2`（其他版本有bug，见[kubesphere论坛][1]），且已安装了 Tiller

集群的可用 `CPU` > `1 C`，可用内存 > `2 G`；

集群已有存储类型（`StorageClass`）。

`metrics-server`，可以执行命令`kubectl  top node`之类
:::


## 安装Kubernetes集群

参见[安装Kubernetes集群][2]

## 安装Helm

参见[安装Helm][3]

## 配置StorageClass

参见[配置StorageClass][4]

## 安装metrics-server

如果使用kubesphere自带metrics-server，则需要开启apiserver的聚合，参考文章也有写

参见[安装metrics-server][5]

-------------------

**以上准备完毕方可开始部署`kubesphere`**

-------------------

```bash
git clone https://github.com/kubesphere/ks-installer.git
# vim kubesphere-minimal.yaml
# 配置etcd地址 endpointIps: 10.255.0.170,10.255.0.171,10.255.0.172
kubectl  apply -f kubesphere-minimal.yaml
sleep 10
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

直到出现下面的日志，方成功！！！

```bash
**************************************************
#####################################################
###              Welcome to KubeSphere!           ###
#####################################################

Console: http://10.255.0.170:30880
Account: admin
Password: P@88w0rd

NOTES：
  1. After logging into the console, please check the
     monitoring status of service components in
     the "Cluster Status". If the service is not
     ready, please wait patiently. You can start
     to use when all components are ready.
  2. Please modify the default password after login.

#####################################################
```


-------------------

## 我碰到的问题

[见论坛][6]

解决方法如下：

当日志到这里时
```bash

TASK [ks-core/ks-core : KubeSphere | Getting Ingress installation files] *******
ok: [localhost] => (item=ingress)
ok: [localhost] => (item=ks-account)
ok: [localhost] => (item=ks-apigateway)
ok: [localhost] => (item=ks-apiserver)
changed: [localhost] => (item=ks-console)
ok: [localhost] => (item=ks-controller-manager)

TASK [ks-core/ks-core : KubeSphere | Creating manifests] ***********************
ok: [localhost] => (item={u'path': u'ingress', u'type': u'config', u'file': u'ingress-controller.yaml'})
changed: [localhost] => (item={u'path': u'ks-account', u'type': u'deployment', u'file': u'ks-account.yml'})
ok: [localhost] => (item={u'path': u'ks-apigateway', u'type': u'deploy', u'file': u'ks-apigateway.yaml'})
changed: [localhost] => (item={u'path': u'ks-apiserver', u'type': u'deploy', u'file': u'ks-apiserver.yml'})
ok: [localhost] => (item={u'path': u'ks-controller-manager', u'type': u'deploy', u'file': u'ks-controller-manager.yaml'})
changed: [localhost] => (item={u'path': u'ks-console', u'type': u'config', u'file': u'ks-console-config.yml'})
ok: [localhost] => (item={u'path': u'ks-console', u'type': u'deploy', u'file': u'ks-console-deployment.yml'})
changed: [localhost] => (item={u'path': u'ks-console', u'type': u'svc', u'file': u'ks-console-svc.yml'})
ok: [localhost] => (item={u'path': u'ks-console', u'type': u'deploy', u'file': u'ks-docs-deployment.yaml'})
ok: [localhost] => (item={u'path': u'ks-console', u'type': u'config', u'file': u'sample-bookinfo-configmap.yaml'})

TASK [ks-core/ks-core : KubeSphere | Creating Ingress-controller configmap] ****
changed: [localhost]

TASK [ks-core/ks-core : KubeSphere | Check ks-account version] *****************
changed: [localhost]

TASK [ks-core/ks-core : KubeSphere | Update kubectl image] *********************
skipping: [localhost]

TASK [ks-core/ks-core : KubeSphere | Creating ks-core] *************************
changed: [localhost] => (item={u'path': u'ks-apigateway', u'file': u'ks-apigateway.yaml'})
changed: [localhost] => (item={u'path': u'ks-apiserver', u'file': u'ks-apiserver.yml'})
changed: [localhost] => (item={u'path': u'ks-account', u'file': u'ks-account.yml'})
changed: [localhost] => (item={u'path': u'ks-controller-manager', u'file': u'ks-controller-manager.yaml'})
changed: [localhost] => (item={u'path': u'ks-console', u'file': u'ks-console-config.yml'})
changed: [localhost] => (item={u'path': u'ks-console', u'file': u'sample-bookinfo-configmap.yaml'})
changed: [localhost] => (item={u'path': u'ks-console', u'file': u'ks-console-deployment.yml'})
changed: [localhost] => (item={u'path': u'ks-console', u'file': u'ks-console-svc.yml'})

PLAY RECAP *********************************************************************
localhost                  : ok=32   changed=22   unreachable=0    failed=0    skipped=5    rescued=0    ignored=0   
```

需要执行以下脚本

```bash
[root@k8s-master ks-installer]# cat restart.sh 
kubectl scale -n kubesphere-system deployment ks-account --replicas=0
kubectl scale -n kubesphere-system deployment ks-account --replicas=1

kubectl scale -n kubesphere-system deployment ks-apigateway --replicas=0
kubectl scale -n kubesphere-system deployment ks-apigateway --replicas=1

kubectl scale -n kubesphere-system deployment ks-apiserver --replicas=0
kubectl scale -n kubesphere-system deployment ks-apiserver --replicas=1

kubectl scale -n kubesphere-system deployment ks-console --replicas=0
kubectl scale -n kubesphere-system deployment ks-console --replicas=1

kubectl scale -n kubesphere-system deployment ks-controller-manager --replicas=0
kubectl scale -n kubesphere-system deployment ks-controller-manager --replicas=1

#kubectl scale -n kubesphere-system deployment --all --replicas=1     

watch kubectl get deployments -n kubesphere-system
# watch一下deployments都为READY状态
[root@k8s-master ks-installer]# 
```

因为有几个 ks 组件起不来, 需要手动 scale 

这个BUG，kubesphere的大佬们会后续在会在ks-installer修正！

没有创建服务按钮解决

https://kubesphere.com.cn/forum/d/251

## 安装新组件

PS:本文是mini安装，如果需要安装新组件，edit保存，查看log就OK！

```bash
kubectl edit cm -n kubesphere-system ks-installer
```

etcd监控须安装证书

```bash
kubectl -n kubesphere-system create secret generic kubesphere-ca  --from-file=ca.crt=/k8s/kubernetes/ssl/ca.pem  --from-file=ca.key=/k8s/kubernetes/ssl/ca-key.pem 
kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  --from-file=etcd-client-ca.crt=/k8s/etcd/ssl/ca.pem   --from-file=etcd-client.crt=/k8s/etcd/ssl/ca.pem  --from-file=etcd-client.key=/k8s/etcd/ssl/ca-key.pem
```

## 卸载

安装过程出现问题，想卸载干净，如下

```bash
kubectl  delete -f kubesphere-minimal.yaml 

#此脚本删除pod和ns不干净，还得手动清除一些，不过也不多
sh scripts/kubesphere-delete.sh

清除nfs空间
```


  [1]: https://kubesphere.com.cn/forum/d/138-2-1-log
  [2]: https://linux48.com/container/2019-09-11-k8s-bin-install.html
  [3]: https://linux48.com/container/2019-11-07-helm.html
  [4]: https://linux48.com/container/2019-11-12-config-storageclass.html
  [5]: https://linux48.com/container/2019-11-13-metrics-server.html
  [6]: https://kubesphere.com.cn/forum/d/138-2-1-log/14
