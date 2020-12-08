---
title: gitlab升级
date: 2017-05-21
tags:
- gitlab
categories:
 - System
---


```bash
bitnami版gitlab

# 复制一份到测试环境，用来测试升级

[root@DB152 dbdata]# tar zcvf gitlab-7.13.1-0.tar.gz   gitlab-7.13.1-0/
[root@DB152 dbdata]# scp gitlab-7.13.1-0.tar.gz   root@10.10.3.225:/dbdata


[root@3-225 backups]# tar zxvf gitlab-7.13.1-0.tar.gz

useradd git
useradd gitlab_ci
useradd postgres
useradd redis

cd /dbdata/gitlab-7.13.1-0/
chown -R git.git ./
chown -R postgres.postgres /dbdata/gitlab-7.13.1-0/postgresql
chown -R redis.redis /dbdata/gitlab-7.13.1-0/redis
chown -R gitlab_ci.gitlab_ci /dbdata/gitlab-7.13.1-0/apps/gitlabci



ln -s /dbdata/gitlab-7.13.1-0/apps/gitlab/gitlab-shell  /home/git/gitlab-shell
ln -s /dbdata/gitlab-7.13.1-0/apps/gitlabci/gitlabci-runner  /home/gitlab_ci/gitlabci-runner

sh ctlscript.sh  start

http://10.10.3.225/

***



sh /dbdata/gitlab-7.13.1-0/ctlscript.sh stop
sh /dbdata/gitlab-7.13.1-0/ctlscript.sh start postgresql
sh /dbdata/gitlab-7.13.1-0/ctlscript.sh start redis




备份GitLab


yum -y install build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate python-docutils pkg-config cmake  

cd /dbdata/gitlab-7.13.1-0/apps/gitlab/htdocs/
ruby -Ilib -e 'require "gitlab/upgrader"' -e 'class Gitlab::Upgrader' -e 'def latest_version_raw' -e '"v8.1.0"' -e 'end' -e 'end' -e 'Gitlab::Upgrader.new.execute'

Post-install message from httparty:
When you HTTParty, you must party hard!
Post-install message from haml:

***

 -> bundle exec rake cache:clear
WARNING: This version of GitLab depends on gitlab-shell 2.6.5, but you're running 2.6.3. Please update gitlab-shell.
 -> OK
Done

# 提示必须使用 gitlab-shell 2.6.5  升级一下 gitlab-shell

cd /dbdata/gitlab-7.13.1-0/apps/gitlab/gitlab-shell/
git stash
git fetch https://github.com/gitlabhq/gitlab-shell
git pull              #拉取远程库的更新，由此命令可以知道 gitlab-shell文件夹下面是一个git库
git checkout v2.6.5   #在这里checkout 最新版本即可，通过 git branch -a 可以查看 pull了哪些版本
git stash apply



cd /dbdata/gitlab-7.13.1-0/
sh ctlscript.sh restart

参考

http://blog.csdn.net/llsmingyi/article/details/50536134

http://doc.gitlab.com/ce/update/upgrader.html

http://doc.gitlab.com/ce/update/patch_versions.html

http://gems.ruby-china.org/

http://www.tuicool.com/articles/iuq2myE

https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/update/7.14-to-8.0.md

BitnamiGitLab升级以及Troubledshooting

https://community.bitnami.com/t/gitlab-8-1-3-continuous-integration-errors/38071/9

https://community.bitnami.com/t/http-cannot-access-repository-for-push/38085



################last######################

版本7到8的一个最重要的变化是 使用http clone代码的模块改动了

由于8.0版本以后 http 请求通过 gitlab-workhorse(gitlab-git-http-server)来处理

Starting with GitLab 8.2, this project has been renamed to (gitlab-workhorse)


Install gitlab-git-http-server

First we download Go 1.5 and install it into /usr/local/go:

curl --remote-name --progress https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz
echo '5817fa4b2252afdb02e11e8b9dc1d9173ef3bd5a  go1.5.linux-amd64.tar.gz' | shasum -c - && \
  sudo tar -C /usr/local -xzf go1.5.linux-amd64.tar.gz
sudo ln -sf /usr/local/go/bin/{go,godoc,gofmt} /usr/local/bin/
rm go1.5.linux-amd64.tar.gz
Now we download gitlab-git-http-server and install it in /home/git/gitlab-git-http-server:

cd /home/git
sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-git-http-server.git
cd gitlab-git-http-server
sudo -u git -H git checkout 0.2.14
sudo -u git -H make

---经过一番研究发现gitlab-git-http-server无法兼容当前版本为了早点拖坑故放弃升级操作-----

-----------------------------------安装最新版本gitlab-----------------------------------

https://www.gitlab.com.cn/downloads/#centos7

wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-9.1.4-ce.0.el7.x86_64.rpm

rpm -i gitlab-ce-9.1.4-ce.0.el7.x86_64.rpm

# rpm -ivh --nodeps --force  gitlab-ce-10.1.3-ce.0.el6.x86_64.rpm

sudo gitlab-ctl reconfigure

https://docs.gitlab.com.cn/omnibus/maintenance/README.html#starting-and-stopping
https://www.gitlab.com.cn/update/

# 启动Gitlab所有组件
sudo gitlab-ctl start

# 停止Gitlab所有组件
sudo gitlab-ctl stop

# 重启Gitlab所有组件
sudo gitlab-ctl restart

# repositories目录
/var/opt/gitlab/git-data/repositories

http://10.10.3.225

# 新建 group 新建user

# 从旧版gitlab导入新版gitlab  (需要整理当前所有项目)

http://username:passwd@gitlab.e-buychina.com.cn/ebuy3.0/business-point-cib.git

***

# 设置域名;更改仓库存储目录；设置时区

vim  /etc/gitlab/gitlab.rb

external_url 'http://gitlab.e-buychina.com.cn'

git_data_dir "/dbdata/git-data"

gitlab_rails['time_zone'] = 'Asia/Shanghai'

pages_external_url "http://pages.gitlab.e-buychina.com.cn/"

gitlab_pages['enable'] = true


编辑完成后，再sudo gitlab-ctl reconfigure一下，使配置生效

访问
http://gitlab.e-buychina.com.cn

# 测试

```

# gitlab升级

```
# 添加yum源

vim /etc/yum.repos.d/gitlab-ce.repo

[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
gpgcheck=0
enabled=1

yum makecache

yum  update gitlab-ce

------------ 2019-06-02 update ------------

gitlab-rake gitlab:backup:create

yum install -y gitlab-ce-10.8.7

yum update -y  gitlab-ce


https://blog.csdn.net/love8753/article/details/88557036
https://stackoverflow.com/questions/51821278/gitlab-ce-upgrade-fails

```

# CI 研究

```
wget https://nodejs.org/dist/v8.9.3/node-v8.9.3-linux-x64.tar.gz
tar zxvf node-v8.9.3-linux-x64.tar.gz
mv node-v8.9.3-linux-x64 /usr/local/
vim /etc/profile
source  /etc/profile
node -v
npm -v
npm install gitbook-cli -g
gitbook -V


curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash

yum install gitlab-runner

gitlab-ci-multi-runner register    

https://docs.gitlab.com/runner/install/linux-repository.html



https://www.chenxuefei.com/2017/build-gitlab-pages/
http://www.chengweiyang.cn/gitbook/basic-usage/README.html
http://idocbox.com/gitlab-8-5%E4%B9%8B%E6%8C%81%E7%BB%AD%E9%9B%86%E6%88%90%E9%85%8D%E7%BD%AE/
https://stackoverflow.com/questions/40006690/gitlab-runner-the-requested-url-returned-error-403
http://www.xuliangwei.com/xubusi/803.html

https://docs.gitlab.com/ee/administration/pages/index.html

```

# 特殊字符转义

```
Google Chrome 按 F12 打开控制台，

进入Console输入

encodeURIComponent('abc@qq.com')
```

# 用 GitLab CI 进行持续集成


https://segmentfault.com/a/1190000006120164

eg:

```
# requiring the environment of NodeJS 8.9.x LTS (carbon)
image: node:8.9

# add 'node_modules' to cache for speeding up builds
cache:
  paths:
    - node_modules/ # Node modules and dependencies

before_script:
  #- npm install gitbook-cli -g # install gitbook
  - gitbook fetch latest # fetch latest stable version
  - gitbook install # add any requested plugins in book.json
  #- gitbook fetch pre # fetch latest pre-release version

# the 'pages' job will deploy and build your site to the 'public' path
pages:
  stage: deploy
  script:
    - gitbook build . public
  artifacts:
    paths:
      - public
  only:
    - release

```

```
# 定义 stages
stages:
  - deploy
  - push_develop
  - push_release
  - push_master
  - push_develop_alipay


# the 'pages' job will deploy and build your site to the 'public' path
pages:
  stage: deploy
  script:
    - gitstats  . public
  artifacts:
    paths:
      - public
  only:
    - develop # this job will affect only the 'develop' branch



# 定义 job
job1:
  stage: push_develop
  script:
    - echo '清除缓存'
    - rm -rf /home/gitlab-runner/pack/efulicore
    - rm -rf /home/gitlab-runner/pack2/efulicore

    - echo '克隆蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack
    - /usr/local/git-2.3.0/bin/git clone  https://test_user%40test-git.com:passwd@git.test-git22.com/efuli/efulicore.git
    - cd efulicore
    - /usr/local/git-2.3.0/bin/git checkout develop
    
    - echo '克隆本地efulicore代码'
    - cd /home/gitlab-runner/pack2
    - /usr/local/git-2.3.0/bin/git clone  http://clone:ebuychina@git.e-fuli.com/welfare/efulicore.git

    - echo '删除蚂蚁云操作'
    - cd /home/gitlab-runner/pack/efulicore
    - /usr/local/git-2.3.0/bin/git checkout develop
    - rm -rf *

    - echo '拷贝本地代码到蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack2/efulicore
    - /usr/local/git-2.3.0/bin/git checkout develop
    - cp -r * /home/gitlab-runner/pack/efulicore

    - echo '提交本地代码到蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack/efulicore
    - /usr/local/git-2.3.0/bin/git remote rm origin
    - /usr/local/git-2.3.0/bin/git config --global user.name "麻晓磊"
    - /usr/local/git-2.3.0/bin/git config --global user.email "maxiaolei@test-git.com"
    - /usr/local/git-2.3.0/bin/git add -A
    - /usr/local/git-2.3.0/bin/git commit -m "提交"
    - /usr/local/git-2.3.0/bin/git remote add origin https://test_user%40test-git.com:passwd@git.test-git22.com/efuli/efulicore.git
    - /usr/local/git-2.3.0/bin/git push -u origin develop
    


  only:
    - develop # this job will affect only the 'develop' branch



# 定义 job
job2:
  stage: push_release
  script:
    - echo '清除缓存'
    - rm -rf /home/gitlab-runner/pack/efulicore
    - rm -rf /home/gitlab-runner/pack2/efulicore

    - echo '克隆蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack
    - /usr/local/git-2.3.0/bin/git clone  https://test_user%40test-git.com:passwd@git.test-git22.com/efuli/efulicore.git
    - cd efulicore
    - /usr/local/git-2.3.0/bin/git checkout release
    
    - echo '克隆本地efulicore代码'
    - cd /home/gitlab-runner/pack2
    - /usr/local/git-2.3.0/bin/git clone  http://clone:ebuychina@git.e-fuli.com/welfare/efulicore.git

    - echo '拷贝本地代码到蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack2/efulicore
    - /usr/local/git-2.3.0/bin/git checkout release
    - cp -r * /home/gitlab-runner/pack/efulicore

    - echo '删除蚂蚁云操作'
    - cd /home/gitlab-runner/pack/efulicore
    - /usr/local/git-2.3.0/bin/git checkout release
    - rm -rf *

    - echo '提交本地代码到蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack/efulicore
    - /usr/local/git-2.3.0/bin/git remote rm origin
    - /usr/local/git-2.3.0/bin/git config --global user.name "麻晓磊"
    - /usr/local/git-2.3.0/bin/git config --global user.email "maxiaolei@test-git.com"
    - /usr/local/git-2.3.0/bin/git add -A
    - /usr/local/git-2.3.0/bin/git commit -m "提交"
    - /usr/local/git-2.3.0/bin/git remote add origin https://test_user%40test-git.com:passwd@git.test-git22.com/efuli/efulicore.git
    - /usr/local/git-2.3.0/bin/git push -u origin release

  only:
    - release # this job will affect only the 'release' branch



# 定义 job
job3:
  stage: push_master
  script:
    - echo '清除缓存'
    - rm -rf /home/gitlab-runner/pack/efulicore
    - rm -rf /home/gitlab-runner/pack2/efulicore

    - echo '克隆蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack
    - /usr/local/git-2.3.0/bin/git clone  https://test_user%40test-git.com:passwd@git.test-git22.com/efuli/efulicore.git
    - cd efulicore
    - /usr/local/git-2.3.0/bin/git checkout master
    
    - echo '克隆本地efulicore代码'
    - cd /home/gitlab-runner/pack2
    - /usr/local/git-2.3.0/bin/git clone  http://clone:ebuychina@git.e-fuli.com/welfare/efulicore.git

    - echo '删除蚂蚁云操作'
    - cd /home/gitlab-runner/pack/efulicore
    - /usr/local/git-2.3.0/bin/git checkout master
    - rm -rf *

    - echo '拷贝本地代码到蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack2/efulicore
    - /usr/local/git-2.3.0/bin/git checkout master
    - cp -r * /home/gitlab-runner/pack/efulicore

    - echo '提交本地代码到蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack/efulicore
    - /usr/local/git-2.3.0/bin/git remote rm origin
    - /usr/local/git-2.3.0/bin/git config --global user.name "麻晓磊"
    - /usr/local/git-2.3.0/bin/git config --global user.email "maxiaolei@test-git.com"
    - /usr/local/git-2.3.0/bin/git add -A
    - /usr/local/git-2.3.0/bin/git commit -m "提交"
    - /usr/local/git-2.3.0/bin/git remote add origin https://test_user%40test-git.com:passwd@git.test-git22.com/efuli/efulicore.git
    - /usr/local/git-2.3.0/bin/git push -u origin master


  only:
    - master # this job will affect only the 'master' branch



# 定义 job
job4:
  stage: push_develop_alipay
  script:
    - echo '清除缓存'
    - rm -rf /home/gitlab-runner/pack/efulicore
    - rm -rf /home/gitlab-runner/pack2/efulicore

    - echo '克隆蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack
    - /usr/local/git-2.3.0/bin/git clone  https://test_user%40test-git.com:passwd@git.test-git22.com/efuli/efulicore.git
    - cd efulicore
    - /usr/local/git-2.3.0/bin/git checkout develop_alipay
    
    - echo '克隆本地efulicore代码'
    - cd /home/gitlab-runner/pack2
    - /usr/local/git-2.3.0/bin/git clone  http://clone:ebuychina@git.e-fuli.com/welfare/efulicore.git

    - echo '删除蚂蚁云操作'
    - cd /home/gitlab-runner/pack/efulicore
    - /usr/local/git-2.3.0/bin/git checkout develop_alipay
    - rm -rf *

    - echo '拷贝本地代码到蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack2/efulicore
    - /usr/local/git-2.3.0/bin/git checkout develop_alipay
    - cp -r * /home/gitlab-runner/pack/efulicore

    - echo '提交本地代码到蚂蚁云efulicore'
    - cd /home/gitlab-runner/pack/efulicore
    - /usr/local/git-2.3.0/bin/git remote rm origin
    - /usr/local/git-2.3.0/bin/git config --global user.name "麻晓磊"
    - /usr/local/git-2.3.0/bin/git config --global user.email "maxiaolei@test-git.com"
    - /usr/local/git-2.3.0/bin/git add -A
    - /usr/local/git-2.3.0/bin/git commit -m "提交"
    - /usr/local/git-2.3.0/bin/git remote add origin https://test_user%40test-git.com:passwd@git.test-git22.com/efuli/efulicore.git
    - /usr/local/git-2.3.0/bin/git push -u origin develop_alipay


  only:
    - develop_alipay # this job will affect only the 'develop_alipay' branch

```

# gitstatus

install gitstatus

```
yum -y install gnuplot
gnuplot --version
cd /usr/local/
git clone https://github.com/hoxu/gitstats.git
export PATH=/usr/local/gitstats
```

add .gitlab-ci.yml

```
# the 'pages' job will deploy and build your site to the 'public' path
pages:
  stage: deploy
  script:
    - gitstats  . public
  artifacts:
    paths:
      - public
  only:
    - develop # this job will affect only the 'develop' branch
```




