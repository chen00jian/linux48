---
title: kubectl命令自动补全
date: 2019-12-02
tags:
- kubernetes
categories:
 - Container
---

```bash
yum -y install bash-completion
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)

echo 'source /usr/share/bash-completion/bash_completion'>> /etc/bashrc
echo 'source <(kubectl completion bash)'>> /etc/bashrc
```

参考

https://blog.csdn.net/wenwenxiong/article/details/53105287

