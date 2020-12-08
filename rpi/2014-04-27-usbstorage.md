---
title: 树莓派自动挂载usb移动存储设备
date: 2014-04-27
tags:
- RaspberryPi
categories:
- RaspberryPi
---



首先插上U盘或者移动硬盘到PI，期间PI因为突然有接口插入会因为电流不稳定而重启！

重启后ssh登陆在终端输入 sudo fdisk -l 会显示出已经挂载的存储设备。

你应该看到类似于这样的画面：

```bash
pi@raspberrypi ~ $ sudo fdisk -l

Disk /dev/mmcblk0: 7948 MB, 7948206080 bytes
4 heads, 16 sectors/track, 242560 cylinders, total 15523840 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x000981cb

Device Boot      Start         End      Blocks   Id  System
/dev/mmcblk0p1            8192      122879       57344    c  W95 FAT32 (LBA)
/dev/mmcblk0p2          122880    15523839     7700480   83  Linux

Disk /dev/sda: 16.0 GB, 16008609792 bytes
69 heads, 42 sectors/track, 10789 cylinders, total 31266816 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x29d229d1

Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *      753408    31266815    15256704    c  W95 FAT32 (LBA)
```


/dev/mmc是树莓派系统的分区，mmc指的是SD卡。

/dev/sda1和/dev/sdb1和SD卡没有关系，这些是你插上去的USB硬盘。

安装ntfs-3g模块，于是我们就能读写NTFS格式的硬盘了。

```bash
sudo apt-get install ntfs-3g
```

然后创建一个目录，以这个目录作为挂载点挂载硬盘，把移动设备挂载上去。

```bash
sudo mkdir -p /media
sudo sudo mount /dev/sda1 /media
```


然后df -lh就可以看到已经挂载成功

```bash
pi@raspberrypi ~ $ df -lh
Filesystem      Size  Used Avail Use% Mounted on
rootfs          7.2G  2.1G  4.8G  31% /
/dev/root       7.2G  2.1G  4.8G  31% /
devtmpfs        211M     0  211M   0% /dev
tmpfs            44M  232K   44M   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sda1        15G  269M   15G   2% /media/__ë__U__
tmpfs            88M     0   88M   0% /run/shm
/dev/mmcblk0p1   56M   19M   38M  34% /boot
```


每次开机都要手动敲命令来让树莓派自动挂载U盘，是一件很不愉快的事情。

我们可以在udev设备管理器新建规则。

```bash
pi@raspberrypi ~ $ sudo vi /etc/udev/rules.d/10-usbstorage.rules

KERNEL!="sd*", GOTO="media_by_label_auto_mount_end"
SUBSYSTEM!="block",GOTO="media_by_label_auto_mount_end"
IMPORT{program}="/sbin/blkid -o udev -p %N"
ENV{ID_FS_TYPE}=="", GOTO="media_by_label_auto_mount_end"
ENV{ID_FS_LABEL}!="", ENV{dir_name}="%E{ID_FS_LABEL}"
ENV{ID_FS_LABEL}=="", ENV{dir_name}="Untitled-%k"
ACTION=="add", ENV{mount_options}="relatime,sync"
ACTION=="add", ENV{ID_FS_TYPE}=="vfat", ENV{mount_options}="iocharset=utf8,umask=000"
ACTION=="add", ENV{ID_FS_TYPE}=="ntfs", ENV{mount_options}="iocharset=utf8,umask=000"
ACTION=="add", RUN+="/bin/mkdir -p /media/%E{dir_name}", RUN+="/bin/mount -o $env{mount_options} /dev/%k /media/%E{dir_name}"

ACTION=="remove", ENV{dir_name}!="", RUN+="/bin/umount -l /media/%E{dir_name}", RUN+="/bin/rmdir /media/%E{dir_name}"
LABEL="media_by_label_auto_mount_end"
```


发现usb移动存储设备会自动挂载到 /media 目录下,可自行修改路径, 挂载到其他目录。

