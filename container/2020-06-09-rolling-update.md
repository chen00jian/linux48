---
title: Deployment滚动升级和回滚
date: 2020-06-09
tags:
- kubernetes
categories:
 - Container
---


大致流程如下

```bash
### 初始化创建项目 ###
kubectl create -f /app/yaml/demo.yaml --record

### 后续发布更新 都采用 set image ###
kubectl set image deployment nginx-demo-server nginx-demo-server=system386/nginx-ingress-demo:0.2 --record

### 查看发布历史 ###
kubectl rollout history deployment nginx-demo-server

### 回滚到上一个版本 ###
kubectl rollout undo deployment nginx-deployment

### 回滚到指定版本 ###
kubectl rollout undo deployment nginx-deployment --to-revision=2

### 查看第二版本变更详情 ###
kubectl rollout history deployment nginx-demo-server --revision=2
```


以下为演示

```bash {12,13,14,15,16,17,18,19,20,30}
[root@k8s-master yaml]$cat /app/yaml/demo.yaml

# ------------------- App Deployment ------------------- #
apiVersion: apps/v1
kind: Deployment
#kind: DaemonSet
metadata:
  name: nginx-demo-server
spec:
  replicas: 2           #relicas指定容器副本数量，默认为1

  ##升级回滚策略
  revisionHistoryLimit: 10  #用来设置保留的历史记录数量，默认为2，设置为0时将不能回滚～～
  minReadySeconds: 5        #滚动升级5s后认为该pod就绪,相当于控制升级速度
  strategy:
    # indicate which strategy we want for rolling update
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        #滚动升级时会先启动1个pod(可配百分比)
      maxUnavailable: 1  #滚动升级时允许的最大Unavailable的pod个数(可配百分比)

  selector:
    matchLabels:
      app: nginx-demo-server
  template:
    metadata:
      labels:
        app: nginx-demo-server
    spec:
      terminationGracePeriodSeconds: 40 #k8s将会给应用发送SIGTERM信号，可以用来正确、优雅地关闭应用,默认为30秒
      containers:
        - name: nginx-demo-server
          #image: 'nginxinc/ingress-demo'
          image: 'system386/nginx-ingress-demo:0.3'
          imagePullPolicy: IfNotPresent
          resources:
            limits:
              cpu: "0.5"             #限制pod申请最大的cpu数量为1个cpu
              memory: 1Gi          #申请内存最大值
            requests:
              cpu: "0.2"           #pod申请的cpu数量为0.5个cpu
              memory: 512Mi        #申请内存的最小值
```

## 初始化创建Deployment ##

```bash
[root@k8s-master yaml]$kubectl create -f /app/yaml/demo.yaml --record
deployment.apps/nginx-demo-server created

[root@k8s-master yaml]$kubectl get po
NAME                                 READY   STATUS    RESTARTS   AGE
nginx-demo-server-5b4685c9f6-gkjlh   1/1     Running   0          25s
nginx-demo-server-5b4685c9f6-v88sn   1/1     Running   0          26s
```

## 后续发布更新 都采用 set image ###

```bash
[root@k8s-master yaml]$kubectl set image deployment nginx-demo-server nginx-demo-server=system386/nginx-ingress-demo:0.2 --record
deployment.apps/nginx-demo-server image updated
```

## 可以再开一个终端watch观看发布过程 ###

```bash
[root@k8s-master yaml]$watch -n 1 -d  'kubectl describe deployments.apps  nginx-demo-server'

#kubectl也支持watch功能，也可以
[root@k8s-master yaml]$kubectl get deployments.apps  nginx-demo-server -w 
[root@k8s-master yaml]$kubectl get replicasets.apps -w
```

## 查看发布历史 ###

```bash
[root@k8s-master yaml]$kubectl rollout history deployment nginx-demo-server
deployment.apps/nginx-demo-server 
REVISION  CHANGE-CAUSE
1         kubectl create --filename=/app/yaml/demo.yaml --record=true
2         kubectl set image deployment nginx-demo-server nginx-demo-server=system386/nginx-ingress-demo:0.2 --record=true
```

## 查看第二版本变更详情 ###

```bash
[root@k8s-master yaml]$kubectl rollout history deployment nginx-demo-server --revision=2
deployment.apps/nginx-demo-server with revision #2
Pod Template:
  Labels:       app=nginx-demo-server
        pod-template-hash=855c946d55
  Annotations:  kubernetes.io/change-cause: kubectl set image deployment nginx-demo-server nginx-demo-server=system386/nginx-ingress-demo:0.2 --record=true
  Containers:
   nginx-demo-server:
    Image:      system386/nginx-ingress-demo:0.2
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:      500m
      memory:   1Gi
    Requests:
      cpu:      200m
      memory:   512Mi
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>
```



参考：

https://www.jianshu.com/p/7411d15215b5

https://blog.csdn.net/chenleiking/article/details/80197975

https://blog.8mi.net/Kubernetes/88.html

https://www.jianshu.com/p/1f54ad627cb7

https://www.cnblogs.com/weifeng1463/p/10431736.html
