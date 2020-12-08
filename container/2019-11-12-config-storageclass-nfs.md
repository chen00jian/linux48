---
title: k8s配置并使用storageclass-nfs
date: 2019-11-12
tags:
- storageclass
- nfs
- pvc
- kubernetes
categories:
 - Container
---



通过 `PVC` 请求到一定的存储空间也很有可能不足以满足应用对于存储设备的各种需求，而且不同的应用程序对于存储性能的要求可能也不尽相同，比如读写速度、并发性能等，为了解决这一问题，Kubernetes 又为我们引入了一个新的资源对象：`StorageClass`，通过 `StorageClass` 的定义，管理员可以将存储资源定义为某种类型的资源，比如快速存储、慢速存储等，用户根据 StorageClass 的描述就可以非常直观的知道各种存储资源的具体特性了，这样就可以根据应用的特性去申请合适的存储资源了。

**为什么要使用storageclass**

一个很简单的例子

```bash
$ cat app.yaml
.......
          volumeMounts:
            - name: timezone
              mountPath: /etc/localtime
            - name: applog
              mountPath: /app/logs
      volumes:
        - name: timezone
          hostPath:
            path: /usr/share/zoneinfo/Asia/Shanghai
        - name: applog
          hostPath:
            path: /app/logs/paas-app
            type: DirectoryOrCreate
```

可见以后挂载的数量越多，越难维护。如果是生产环境那这样不是一个好的方案


**使用`NFS`创建`StorageClass`持久化存储**

创建`NFS`服务器，共享`/k8s/nfs_data/`目录，详情见[CentOS NFS的安装配置、启动及mount挂载方法][1]

```bash
$ systemctl stop firewalld.service
$ yum -y install nfs-utils rpcbind
$ mkdir -p /k8s/nfs_data
$ chmod 755 /k8s/nfs_data
$ vim /etc/exports
/k8s/nfs_data  *(rw,sync,no_root_squash)
$ systemctl enable rpcbind.service
$ systemctl enable nfs.service
$ systemctl start rpcbind.service
$ systemctl start nfs.service
```

**node服务器安装nfs软件包**

```bash
yum install nfs-common  nfs-utils -y
```


**创建storageclass**

<RecoDemo  :collapse="true">
  <template slot="code-nfs-dp.yaml">
    <<< @/docs/.vuepress/script_demo/nfs-client.yaml
  </template>
  <template slot="code-nfs-rbac.yaml">
    <<< @/docs/.vuepress/script_demo/nfs-client-sa.yaml
  </template>
  <template slot="code-nfs-sc.yaml">
    <<< @/docs/.vuepress/script_demo/nfs-client-class.yaml
  </template>
</RecoDemo>

```bash
[root@k8s-master nfs]# kubectl create -f nfs-dp.yaml
[root@k8s-master nfs]# kubectl create -f nfs-rbac.yaml
[root@k8s-master nfs]# kubectl create -f nfs-sc.yaml 

[root@k8s-master nfs]# kubectl  get pods |grep nfs
nfs-client-provisioner-6f5d588-mq6l2    1/1     Running            1          2d1h

[root@k8s-master nfs]# kubectl get storageclass
NAME                           PROVISIONER      AGE
course-nfs-storage   fuseim.pri/ifs   2d1h

# 设置默认storageclass
# https://kubernetes.io/zh/docs/tasks/administer-cluster/change-default-storage-class/
[root@k8s-master nfs]# kubectl patch storageclass course-nfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

[root@k8s-master nfs]# kubectl get sc
NAME                           PROVISIONER      AGE
course-nfs-storage (default)   fuseim.pri/ifs   2d1h
[root@k8s-master nfs]# 
```

**创建PVC**

```bash
[root@k8s-master grafana]$cat test-pvc.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: course-nfs-storage    #存储类名，集群中已存在的
  resources:
    requests:
      storage: 1Gi

[root@k8s-master nfs]# kubectl apply -f test-pvc.yaml 
persistentvolumeclaim/test-pvc created
[root@k8s-master nfs]# kubectl get pvc
NAME       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
test-pvc   Bound    pvc-852cb52e-f126-451a-a8c0-a405c79d97a6   1Gi        RWX            course-nfs-storage   7s
```

**引用PVC**

```bash {23,24,25,26,27,28,29}
[root@k8s-master nfs]# cat nginx-pvc.yaml 
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nginx-demo-1
  labels:
    app: nginx-demo-1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-demo-1
  template:
    metadata:
      labels:
        app: nginx-demo-1
    spec:
      containers:
      - image: system386/nginx-ingress-demo:0.2      
        name: nginx-demo-1      
        imagePullPolicy: IfNotPresent

        volumeMounts:
        - name: data
          mountPath: /opt/test
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: test-pvc    # 刚创建的pvc

[root@k8s-master nfs]# 
[root@k8s-master nfs]# kubectl create -f nginx-pvc.yaml 
deployment.apps/nginx-demo-1 created
```


**测试写入**

```bash
[root@k8s-master pvc]$kubectl exec  -it nginx-demo-1-686f674f88-lxwwn -- /bin/sh

root@nginx-demo-1-686f674f88-lxwwn / 10:41 $ cd /opt/test
root@nginx-demo-1-686f674f88-lxwwn /opt/test 10:41 $ echo  'hello~~~' > test.txt
root@nginx-demo-1-686f674f88-lxwwn /opt/test 10:42 $ cat test.txt 
hello~~~
root@nginx-demo-1-686f674f88-lxwwn /opt/test 10:42 $ exit

[root@k8s-master pvc]$ll /data/nfs_data/default-test-pvc-pvc-852cb52e-f126-451a-a8c0-a405c79d97a6/ 
total 4
-rw-r--r-- 1 root root 9 Jun 19 10:42 test.txt
[root@k8s-master pvc]$cat /data/nfs_data/default-test-pvc-pvc-852cb52e-f126-451a-a8c0-a405c79d97a6/test.txt 
hello~~~
[root@k8s-master pvc]$
```

**StatefulSet模式可直接使用storageClassName**

```bash {25,26,27,28,29,30,31,32,33,34}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx # has to match .spec.template.metadata.labels
  serviceName: "nginx"  #声明它属于哪个Headless Service.
  replicas: 3 # by default is 1
  template:
    metadata:
      labels:
        app: nginx # has to match .spec.selector.matchLabels
    spec:
      containers:
      - name: nginx
        image: system386/nginx-ingress-demo:0.2
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www-data
          mountPath: /opt/test
  volumeClaimTemplates:   #可看作pvc的模板
  - metadata:
      name: www-data
    spec:
      accessModes:
      - ReadWriteOnce
      storageClassName: "course-nfs-storage"  #存储类名，改为集群中已存在的
      resources:
        requests:
          storage: 1Gi
```




  [1]: https://linux48.com/system/2014-07-31-CentOS-NFS-mount.html
