---
title: centos gitlab一键安装备份恢复和迁移
date: 2014-12-04
tags:
- gitlab
categories:
 - System
---




## 安装

```bash
wget https://downloads.bitnami.com/files/stacks/gitlab/7.4.3-0/bitnami-gitlab-7.4.3-0-linux-x64-installer.run
chmod +x bitnami-gitlab-7.4.3-0-linux-x64-installer.run
./bitnami-gitlab-7.4.3-0-linux-x64-installer.run
```


## 备份和恢复

**备份以及恢复的操作，以下操作使用root用户执行**

1、指定备份路径

```bash
vi /opt/gitlab-7.4.3-0/apps/gitlab/htdocs/config/gitlab.yml
           
## Backup settings
backup:
path: "tmp/backups" # Relative paths are relative to Rails.root (default: tmp/backups/)
##可自定义路径
```
       
2、执行备份

```bash
cd /opt/gitlab-7.4.3-0/
./use_gitlab
cd /opt/gitlab-7.4.3-0/apps/gitlab/htdocs
bundle exec bin/rake gitlab:backup:create RAILS_ENV=production
```

操作执行完毕，会在/opt/gitlab-7.4.3-0/apps/gitlab/htdocs/tmp/backups/目录下生产一个备份文件，类似1438917368_gitlab_backup.tar


3、恢复备份的数据

需要先把备份的tar包拷贝到backu—path

```bash
cd /opt/gitlab-7.4.3-0/
./use_gitlab
cd /opt/gitlab-7.4.3-0/apps/gitlab/htdocs
bundle exec bin/rake gitlab:backup:restore RAILS_ENV=production 
chown git:git -R /opt/gitlab-7.4.3-0/apps/gitlab/repositories
```

如果备份的目录下不止一个备份文件，则RAILS_ENV=production后面需要指定备份文件 BACKUP=xxx。
至此备份恢复完毕。

ps：经过我自己的研究发现可以直接拷贝repositories目录到新机器也是OK的;也成功测试通过。至于正式迁移还是要按照官方文档！

## 迁移

以上备份可以整理成备份脚本，定期备份，也可以用于gitlab服务器迁移（迁移必须使用相同gitlab版本方可兼容）

迁移过程：

1、安装版本一致的bitnami-gitlab

2、设置gitlab服务器hosts和git客户端hosts指向新server

3、启动postfix用来发邮件

4、拷贝备份数据到新server，并导入

5、客户端进行测试

6、测试成功方可正式迁移


### 迁移过程中碰到的问题

### 客户端git pull 提示 gitlab-shell.log Permission denied

``chown -R git.git /dbdata/gitlab-7.13.1-0/apps/gitlab/gitlab-shell/gitlab-shell.log``

### 客户端提示指纹对不上

``rm -rf /root/.ssh/known_hosts``

### gitlab首页不显示commit更新事件

那是因为备份出来的repositories里的hook的软链接还指向的是老server的hook路径

需要依次重新设置每个git仓库的hook，如果新server的gitlab安装路径和老server一样，请忽略

```bash
cd /dbdata/gitlab-7.13.1-0/apps/gitlab/repositories/ops/opslegend.git
rm -rf hooks
ln -s /dbdata/gitlab-7.13.1-0/apps/gitlab/gitlab-shell/hooks hooks
```

### gitlab上传头像报500错误

查看apache的log显示权限不足

```bash
# tail -f /dbdata/gitlab-7.13.1-0/apps/gitlab/htdocs/log/production.log 

Errno::EACCES (Permission denied - /dbdata/gitlab-7.13.1-0/apps/gitlab/htdocs/public/uploads/tmp/1459914127-98234-4213):
  app/controllers/profiles_controller.rb:21:in `update`
```
解决

``chown -R git.git /dbdata/gitlab-7.13.1-0/apps/gitlab/htdocs/public/uploads``



bitnami-gitlab官网: https://bitnami.com/stack/gitlab/installer
