---
title: 安装Kubectl客户端工具
date: 2019-10-15
tags:
- kubernetes
- Kubectl
categories:
 - Container
---


```bash
# https://www.cnblogs.com/iiiiher/p/7920635.html
# https://github.com/harbur/kubernetic/blob/master/README.md


# K8S windows命令客户端
wget https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/windows/amd64/kubectl.exe
# 加到path

# mac下安装kubectl命令
wget https://storage.googleapis.com/kubernetes-release/release/v1.8.13/bin/darwin/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# kubeconfig配置
kubectl config set-cluster local-server --server=http://10.10.10.100:8080
kubectl config set-context default-context --cluster=local-server --namespace=default
kubectl config use-context default-context
kubectl config view
kubectl get pods
```


:::tip K8S 图形客户端
https://kubernetic.com/

wget https://kubernetic.s3.amazonaws.com/Kubernetic+Setup+2.3.0.exe

wget https://kubernetic.s3.amazonaws.com/Kubernetic-2.3.0.dmg
:::
