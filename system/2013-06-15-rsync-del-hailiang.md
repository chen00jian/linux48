---
title: 使用rsync删除海量文件
date: 2013-06-15
tags:
- rsync
categories:
 - System
---


最近微博上很火的一个话题  [#Linux技巧：一次删除一百万个文件的最快方法#][1]

前面有博<a title="深入理解磁盘inode" href="http://linux48.com/archives/215.html" target="_blank">文深入理解磁盘inode</a>就是由于海量的碎片文件造成的

所以要在linux下删除海量文件，比如有数十万个文件，此时常用的rm -rf * 就会等待时间很长。这时我们可以使用rsync快速删除大量文件。

<a title="外刊IY评论网的这篇文章" href="http://www.aqee.net/a-faster-way-to-delete-millions-of-files-in-a-directory/" target="_blank">外刊IT评论的这篇文章</a> 就讲到过使用rsync的效率之高了

下面我们演示一下如何操作

1，建立一个空目录test1111，并在里面写入文件，此文件夹是后面需要清空的

```bash
# mkdir test1111
# cd test1111/
# touch 1111111111111
# touch 2222222222222
# touch 3333333333333
# touch 4444444444444
# touch 5555555555555
```

2，建立一个空目录null123，此文件夹是为了让test1111文件夹同步空内容，以便达到删除目的

```bash
mkdir null123
```

3，使用rsync删除目标目录

```bash
# rsync --delete-before -a -H -v -P --stats /home/null123/ /home/test1111/
building file list ... 
1 file to consider
deleting 5555555555555
deleting 4444444444444
deleting 3333333333333
deleting 2222222222222
deleting 1111111111111
./

Number of files: 1
Number of files transferred: 0
Total file size: 0 bytes
Total transferred file size: 0 bytes
Literal data: 0 bytes
Matched data: 0 bytes
File list size: 19
File list generation time: 0.001 seconds
File list transfer time: 0.000 seconds
Total bytes sent: 29
Total bytes received: 15

sent 29 bytes  received 15 bytes  88.00 bytes/sec
total size is 0  speedup is 0.00
#ll /home/test1111/
total 0
```

加入 /usr/bin/time -v 可显示过程时长

附图

<img class="alignnone" alt="" src="https://i.loli.net/2019/10/18/7zkn1CWSaJGY9ec.jpg" width="690" height="466" />

 [1]: http://s.weibo.com/weibo/Linux%25E6%258A%2580%25E5%25B7%25A7%25EF%25BC%259A%25E4%25B8%2580%25E6%25AC%25A1%25E5%2588%25A0%25E9%2599%25A4%25E4%25B8%2580%25E7%2599%25BE%25E4%25B8%2587%25E4%25B8%25AA%25E6%2596%2587%25E4%25BB%25B6%25E7%259A%2584%25E6%259C%2580%25E5%25BF%25AB%25E6%2596%25B9?topnav=1&wvr=5&topsug=1 "#Linux技巧：一次删除一百万个文件的最快方法#"
