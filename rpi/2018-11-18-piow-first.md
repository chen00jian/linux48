---
title: PI0W试玩(USB/Ethernet)  一根microUSB线玩转树莓派zeroW
date: 2018-11-18
tags:
- RaspberryPi
categories:
- RaspberryPi
---



##双11买了台口香糖电脑

##准备：

>* PI0W板子
>* TF卡
>* TF读卡器
>* microUSB线
>* windows10笔记本

##开搞

1. 格式化TF卡   (windows自带磁盘管理即可格式化)

2. 用**win32diskimager**烧录**2018-11-13-raspbian-stretch-lite.img**

3. 配置**boot**   (**windows**下烧录完**boot**分区会以**FAT32**暴露出来)

用**Notepad++**编辑

**config.txt**   末端加一行 `dtoverlay=dwc2`

**cmdline.txt**   `rootwait`后面加`modules-load=dwc2,g_ether`**注意空格**

新建空文本文件改名**ssh**

4. `microUSB线`插**PI0W**的`usb口`和电脑连接起来

5. 这时**Win10**下设备会被识别为**COM**设备,在设备管理器中更新该驱动程序

驱动程序下载地址

https://pan.baidu.com/s/18v-LLt7_gDIHKfJRoBbqvA

6. 安装完驱动即可被识别为名为**USB Ethernet/RNDIS Gadget**的网卡

网卡状态未识别的网络,ip为`169.254.71.246`类似

**需要注意的是**

**这个IP地址并不是树莓派地址,而是RNDIS网卡地址**

**树莓派还有另一个地址,这个地址查不到又与网卡地址不同,所以需要用`raspberrypi.local`**

**唯一的办法是通过安装Bonjour等软件来让电脑可以支持识别局域网的`raspberrypi.local`主机名**

7. 安装Bonjour

https://pan.baidu.com/s/1WbcUCsI9kWao9zZBnglT3Q

8. ssh连接

```bash
C:\Users\xiaolei.ma>ping raspberrypi.local
正在 Ping raspberrypi.local [f110::71f2:35fd:8g01:5623%65] 具有 32 字节的数据:
来自 f110::71f2:35fd:8g01:5623%65 的回复: 时间<1ms
来自 f110::71f2:35fd:8g01:5623%65 的回复: 时间<1ms
```

**ping**通之后用**SecureCRT**或者**putty**连接`raspberrypi.local`

账户**pi**

密码**raspberry**

如果有**bash**则命令行连接`ssh pi@raspberrypi.local`

9. 设置

`sudo raspi-config`设置**wifi**相关

设置完成后`ifconfig`发现**wlan0**通过**DHCP**获取到**IP**,以后即可通过**IP**地址连接

```bash
pi@raspberrypi:~ $ ifconfig
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
inet 127.0.0.1  netmask 255.0.0.0
inet6 ::1  prefixlen 128  scopeid 0x10<host>
loop  txqueuelen 1000  (Local Loopback)
RX packets 23  bytes 1848 (1.8 KiB)
RX errors 0  dropped 0  overruns 0  frame 0
TX packets 23  bytes 1848 (1.8 KiB)
TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

usb0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
inet 169.254.71.246  netmask 255.255.0.0  broadcast 169.254.255.255
inet6 f110::71f2:35fd:8g01:5623  prefixlen 64  scopeid 0x20<link>
ether 2g:6h:2g:33:11:11  txqueuelen 1000  (Ethernet)
RX packets 3164  bytes 436325 (426.0 KiB)
RX errors 0  dropped 11  overruns 0  frame 0
TX packets 1299  bytes 293238 (286.3 KiB)
TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
inet 10.10.3.55  netmask 255.255.255.0  broadcast 10.10.3.255
inet6 f3e0::7g7a:345f:bq27:65g6  prefixlen 64  scopeid 0x20<link>
ether 2g:12:12:12:11:11  txqueuelen 1000  (Ethernet)
RX packets 12997  bytes 1198100 (1.1 MiB)
RX errors 0  dropped 0  overruns 0  frame 0
TX packets 459  bytes 67142 (65.5 KiB)
TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

每次`sudo raspi-config`设置**wifi**之后都会写入到这个配置当中`/etc/wpa_supplicant/wpa_supplicant.conf`

注意的是新增而不是覆盖写入

如果范围内同时有多个**WiFi**,则可以手动更改配置文件设置优先级

```bash
pi@raspberrypi:~ $ sudo cat /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=CN

network={
ssid="mamama"
psk="XXX.com"
priority=5   //优先级 数字越大越优先
}

network={
ssid="Tech"
psk="xxx.com"
priority=4   //优先级 数字越大越优先
}
pi@raspberrypi:~ $
```


10. 更换源

```bash
pi@raspberrypi:~ $ sudo cat /etc/apt/sources.list
#deb http://raspbian.raspberrypi.org/raspbian/ stretch main contrib non-free rpi
# Uncomment line below then 'apt-get update' to enable 'apt-get source'
#deb-src http://raspbian.raspberrypi.org/raspbian/ stretch main contrib non-free rpi

deb     http://mirrors.ustc.edu.cn/raspbian/raspbian/ stretch main contrib non-free rpi
deb-src http://mirrors.ustc.edu.cn/raspbian/raspbian/ stretch main contrib non-free rpi
```

11. 安装图形界面

```bash
pi@raspberrypi:~ $ cat install_X.sh
sudo apt-get update -y
sudo apt-get install --no-install-recommends xserver-xorg -y
sudo apt-get install --no-install-recommends xinit -y
sudo apt-get install raspberrypi-ui-mods -y
sudo reboot
```

12. 安装VNC

按顺序安装，一定要按顺序安装

```bash
sudo apt-get install tightvncserver
sudo apt-get install xrdp
```

13. windows--mstsc--pi0w_IP--Xorg

##other

这期间一共研究了两天时间才搞定,其中翻阅各种资料论坛

搜索关键字

**一根线玩树莓派zeroW**

**树莓派zeroW开机**

因为不管提前配好**wifi**还是配成网卡模式,通电都无法看到任何动静,找不到树莓派的IP,只是绿灯再闪

期间换过**raspbian**历史版本,换过TF卡，尝试过各种操作

会不会是板子有问题呢,本来今天想着最后在研究一把,实在研究不出来就退货...

后来换了一根近期买的小米充电宝附赠的usb线,连到电脑显示新增硬件**RNDIS/Ethernet Gadget** 才有了上面这些操作...

**尼玛原来是USB线的坑啊~~~**

##tip

在遇到问题有可能是TF卡有问题,也有可能是USB线,电源的问题,或者是系统不兼容问题

网上的资料有可能会解决你的问题,但不一定完全吻合!

还是得靠自己爬坑

##via

http://shumeipai.nxez.com/2018/02/20/raspberry-pi-zero-usb-ethernet-gadget-tutorial.html

https://www.baidu.com/s?ie=UTF-8&wd=%E4%B8%80%E6%A0%B9%E7%BA%BF%E7%8E%A9%E6%A0%91%E8%8E%93%E6%B4%BEzeroW
