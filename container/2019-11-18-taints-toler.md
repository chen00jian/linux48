---
title: kubernetes-污点和容忍
date: 2019-11-18
tags:
- kubernetes
- taints
categories:
 - Container
---

手动部署的k8s集群, 需要为master节点手动设置taints

设置taint

语法:

```bash
kubectl taint node [node] key=value[effect]   
     其中[effect] 可取值: [ NoSchedule | PreferNoSchedule | NoExecute ]
      NoSchedule: 一定不能被调度
      PreferNoSchedule: 尽量不要调度
      NoExecute: 不仅不会调度, 还会驱逐Node上已有的Pod
```

示例:

```bash
kubectl taint node node1 key1=value1:NoSchedule
kubectl taint node node1 key1=value1:NoExecute
kubectl taint node node1 key2=value2:NoSchedule
```

查看taint：

```bash
kubectl describe node node1
```

删除taint:

```bash
kubectl taint node node1 key1:NoSchedule-  # 这里的key可以不用指定value
kubectl taint node node1 key1:NoExecute-
# kubectl taint node node1 key1-  删除指定key所有的effect
kubectl taint node node1 key2:NoSchedule-
```

master节点设置taint

```bash
kubectl taint nodes master1 node-role.kubernetes.io/master=:NoSchedule
```

::: warning
注意⚠️ : 为master设置的这个taint中, node-role.kubernetes.io/master为key, value为空, effect为NoSchedule
:::

如果输入命令时, 你丢掉了=符号, 写成了node-role.kubernetes.io/master:NoSchedule, 会报error: at least one taint update is required错误

容忍tolerations主节点的taints

以上面为 master1 设置的 taints 为例, 你需要为你的 yaml 文件中添加如下配置, 才能容忍 master 节点的污点

在 pod 的 spec 中设置 tolerations 字段

```
tolerations:
- key: "node-role.kubernetes.io/master"
  operator: "Equal"
  value: ""
  effect: "NoSchedule"
```

-------------------

####补充####

```bash
#设置集群标签和污点

#注意:由于我们master节点也安装了kubelet
#此时不容易发现那个节点是master，那个节点是node，可以给节点设置一个角色标签


$ kubectl label node 172.29.202.145 node-role.kubernetes.io/master=""
$ kubectl label node 172.29.202.151 node-role.kubernetes.io/master=""
$ kubectl label node 172.29.202.155 node-role.kubernetes.io/master=""
$ kubectl label node 172.29.202.159 node-role.kubernetes.io/node=""

# 查看集群节点状态
$ kubectl  get nodes
NAME             STATUS   ROLES    AGE    VERSION
172.29.202.145   Ready    master   14h    v1.16.0
172.29.202.151   Ready    master   14h    v1.16.0
172.29.202.155   Ready    master   14h    v1.16.0
172.29.202.159   Ready    node     7m7s   v1.16.0

# 设置污点，不允许k8s调度pod到master节点
$ kubectl taint nodes 172.29.202.145 node-role.kubernetes.io/master=:NoSchedule
$ kubectl taint nodes 172.29.202.151 node-role.kubernetes.io/master=:NoSchedule
$ kubectl taint nodes 172.29.202.155 node-role.kubernetes.io/master=:NoSchedule

## 此时正常的业务容器不会调度到master节点上

# 给pod配置容忍
$ cat pod.yml
...
tolerations:
- key: "node-role.kubernetes.io/master"
  operator: "Equal"
  value: ""
  effect: "NoSchedule"
#或者
tolerations:
- key: "node-role.kubernetes.io/master"
  operator: "Exists"
  effect: "NoSchedule"

#注意:理解Taints,Tolerations和Affinity

#Taints 和 Node affinity 是对立的概念，用来允许一个 node 拒绝某一类 pods
#Taints 和 tolerations 配合起来可以保证 pods 不会被调度到不合适的 nodes 上干活
#一个 node 上可以有多个 taints
#将tolerations 应用到 pods 来允许被调度到合适的 nodes 上干活
```

参考官方手册

https://kubernetes.io/zh/docs/concepts/configuration/taint-and-toleration/
