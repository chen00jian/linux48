---
title: 使用Markdown On RaspberryPi 写博客
date: 2013-07-06
tags:
- RaspberryPi
categories:
 - RaspberryPi
---



由于之前安装的lnmp环境跑php博客简直就是渣渣的水平

所以在网上参考了众多静博客，其中都有


[Jekyll-Bootstrap](http://www.jekyllbootstrap.com/)

[Gor](https://github.com/wendal/gor)

[ruhoh](http://ruhoh.com/)

最后偶然找到了纯js的博客，直接调用md显示页面的源码,UI也很赞！

[多多de棉花糖](https://github.com/hugcoday/hugcoday.github.com)

下面说一下怎么在树莓派上搭建

1 - Create a New Repository

Go to your https://github.com and create a new repository named koy1619.github.com

注意koy1619为我的github的ID

2 - Install [多多de棉花糖](https://github.com/hugcoday/hugcoday.github.com)

```bash
$ git clone https://github.com/hugcoday/hugcoday.github.com.git koy1619.github.com
$ cd koy1619.github.com
$ git remote set-url origin git@github.com:koy1619/koy1619.github.com.git
$ git push origin master
```

3 - 其中还需要注意需要在 https://github.com/settings/emails 设置一个认证邮箱，不然会报404

4 - 根据README.md方法，用Markdown新建一篇文章，这里推荐一个很好用的Markdown在线编辑器

http://mahua.jser.me/

在编辑器写完文章之后，粘贴到2012-12-12-hello-world.md

cd /home/pi/koy1619.github.com/post/

vi 2012-12-12-hello-world.md

根据README.md方法，配置index.json

5 - 编写更新github脚本 upload.sh

```bash
cd /home/pi/koy1619.github.com/
git init
git add -A
git commit -m "add new blog" .
git remote set-url origin git@github.com:koy1619/koy1619.github.com.git
git push -u origin master
    
sudo chmod 777 upload.sh

sudo ./upload.sh
```

6 - 等待10分钟，就可以通过http://koy1619.github.com访问啦

7 - mysql和php-fpm可以停掉了，设置nginx域名和虚拟主机指向/home/pi/koy1619.github.com/ 重启nginx即可通过域名访问

附：关于git在树莓派的安装和使用参见[github安装使用](http://linux48.com/archives/260.html)
