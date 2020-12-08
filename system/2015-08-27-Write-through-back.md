---
title: MegaCli使用技巧-阵列Cache写机制：Write-through与Write-back
date: 2015-08-27
tags:
- MegaCli
- Cache
categories:
 - System
---





<blockquote class="blockquote-center">Write Through和Write Back是阵列卡Cache的两种使用方式，也称为透写和回写。当选用write through方式时，系统的写磁盘操作并不利用阵列卡的Cache，而是直接与磁盘进行数据的交互。而write Back方式则利用阵列Cache作为系统与磁盘间的二传手，系统先将数据交给Cache，然后再由Cache将数据传给磁盘。</blockquote>


最近在部署马来西亚DBServer的时候发现DB1的硬盘写入速度比DB2要慢好多

![][1]

![][2]

两台服务器在导入数据的过程中对硬盘测速结果如下

![][3]

![][4]

机房给出的解释也是一切正常

后来老大帮忙推荐MegaCli工具去排查问题所在

发现DB1的Cache写机制为Write-through而DB2为Write-back

```bash
[root@DBServer1 MegaCli]# ./MegaCli64 -Ldinfo -lall -aall
                                     

Adapter 0 -- Virtual Drive Information:
Virtual Drive: 0 (Target Id: 0)
Name                :
RAID Level          : Primary-5, Secondary-0, RAID Level Qualifier-3
Size                : 557.75 GB
Sector Size         : 512
Parity Size         : 278.875 GB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives    : 3
Span Depth          : 1
Default Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteThrough, ReadAheadNone, Direct, No Write Cache if Bad BBU
Default Access Policy: Read/Write
Current Access Policy: Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Is VD Cached: No



Exit Code: 0x00
[root@DBServer1 MegaCli]# 
```

```bash
[root@DBServer2 MegaCli]# ./MegaCli64 -Ldinfo -lall -aall
                                     

Adapter 0 -- Virtual Drive Information:
Virtual Drive: 0 (Target Id: 0)
Name                :
RAID Level          : Primary-5, Secondary-0, RAID Level Qualifier-3
Size                : 557.75 GB
Sector Size         : 512
Parity Size         : 278.875 GB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives    : 3
Span Depth          : 1
Default Cache Policy: WriteBack, ReadAheadNone, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteBack, ReadAheadNone, Direct, No Write Cache if Bad BBU
Default Access Policy: Read/Write
Current Access Policy: Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Is VD Cached: No



Exit Code: 0x00
[root@DBServer2 MegaCli]# 

```

**以下为搜到的科普内容**

Cache写机制

参考 http://en.wikipedia.org/wiki/Cache#Writing_Policies 上的说明，**Cache**写机制分为**write through**和**write back**两种。

>* **Write-through** Write is done synchronously both to the cache and to the backing store.
>* **Write-back** (or Write-behind) – Writing is done only to the cache. A modified cache block is written back to the store, just before it is replaced.

**Write-through**（直写模式）在数据更新时，同时写入缓存Cache和后端存储。此模式的优点是操作简单；缺点是因为数据修改需要同时写入存储，数据写入速度较慢。

**Write-back**（回写模式）在数据更新时只写入缓存Cache。只在数据被替换出缓存时，被修改的缓存数据才会被写到后端存储。此模式的优点是数据写入速度快，因为不需要写存储；缺点是一旦更新后的数据未被写入存储时出现系统掉电的情况，数据将无法找回。

**Write-misses写缺失的处理方式**

对于写操作，存在写入缓存缺失数据的情况，这时有两种处理方式：

>* **Write allocate** (aka Fetch on write) – Datum at the missed-write location is loaded to cache, followed by a write-hit operation. In this approach, write misses are similar to read-misses.
>* **No-write allocate** (aka Write-no-allocate, Write around) – Datum at the missed-write location is not loaded to cache, and is written directly to the backing store. In this approach, actually only system reads are being cached.

**Write allocate**方式将写入位置读入缓存，然后采用write-hit（缓存命中写入）操作。写缺失操作与读缺失操作类似。

**No-write allocate**方式并不将写入位置读入缓存，而是直接将数据写入存储。这种方式下，只有读操作会被缓存。

无论是Write-through还是Write-back都可以使用写缺失的两种方式之一。只是通常Write-back采用Write allocate方式，而Write-through采用No-write allocate方式；因为多次写入同一缓存时，Write allocate配合Write-back可以提升性能；而对于Write-through则没有帮助。

**处理流程图**

Write-through模式处理流程：

![][5]

Write-back模式处理流程：

![][6]

在创建raid阵列可选择Write Policy的策略

![][7]

在了解了原理之后可以通过**MegaCli**来设置DB1的**Write Policy**为**WriteBack**

```bash
[root@DBServer1 MegaCli]# ./MegaCli64 -LDSetProp WB -LAll -aAll
                                     
Set Write Policy to WriteBack on Adapter 0, VD 0 (target id: 0) success

Exit Code: 0x00
[root@DBServer1 MegaCli]# 
```

此时在查看DB1的**Write Policy**已经成功设置为**WriteBack**

```bash
[root@DBServer1 MegaCli]# ./MegaCli64 -Ldinfo -lall -aall
                                     

Adapter 0 -- Virtual Drive Information:
Virtual Drive: 0 (Target Id: 0)
Name                :
RAID Level          : Primary-5, Secondary-0, RAID Level Qualifier-3
Size                : 557.75 GB
Sector Size         : 512
Parity Size         : 278.875 GB
State               : Optimal
Strip Size          : 64 KB
Number Of Drives    : 3
Span Depth          : 1
Default Cache Policy: WriteBack, ReadAheadNone, Direct, No Write Cache if Bad BBU
Current Cache Policy: WriteBack, ReadAheadNone, Direct, No Write Cache if Bad BBU
Default Access Policy: Read/Write
Current Access Policy: Read/Write
Disk Cache Policy   : Disk's Default
Encryption Type     : None
Is VD Cached: No



Exit Code: 0x00
[root@DBServer1 MegaCli]# 
```

然后在测试DB1的写入速度，看以看到正常了
![][8]


下一篇文章会着重记录一下**MegaCli**工具的安装与使用

--------------------------

继续科普记录一下


Write Through和Write Back是阵列卡Cache的两种使用方式，也称为透写和回写。当选用write through方式时，系统的写磁盘操作并不利用阵列卡的Cache，而是直接与磁盘进行数据的交互。而write Back方式则利用阵列Cache作为系统与磁盘间的二传手，系统先将数据交给Cache，然后再由Cache将数据传给磁盘。 在配置阵列的时候，如果不是很清楚的话，默认就可以了，系统会根据磁盘类型进行默认设置。

生产环境中的配置要根据具体的业务类型及环境进行配置，比如：如果有外置UPS电源，选Write Back，如果没有外置电源，并且对数据安全性要求很高，不要求太高性能，就选Write Through。Write caching 或 write-through write-through意思是写操作根本不使用缓存。数据总是直接写入磁盘。关闭写缓存，可释放缓存用于读操作。（缓存被读写操作共用） Write caching可以提高写操作的性能。数据不是直接被写入磁盘；而是写入缓存。从应用程序的角度看，比等待完成磁盘写入操作要快的多。因此，可以提高写性能。由控制器将缓存内未写入磁盘的数据写入磁盘。表面上看，Write cache方式比write-through方式的读、写性能都要好，但是也要看磁盘访问方式和磁盘负荷了。 write-back（write cache）方式通常在磁盘负荷较轻时速度更快。负荷重时，每当数据被写入缓存后，就要马上再写入磁盘以释放缓存来保存将要写入的新数据，这时如果数据直接写入磁盘，控制器会以更快的速度运行。因此，负荷重时，将数据先写入缓存反而会降低吞吐量。 Starting and stopping cache flushing levels 这两个设置影响控制器如何处理未写入磁盘的缓存内数据，并且只在write-back cache方式下生效。缓存内数据写入磁盘称为flushing.你可以配置Starting and stopping cache flushing levels值，这个值表示占用整个缓存大小的百分比。当缓存内未写入磁盘的数据达到starting flushing value时，控制器开始flushing（由缓存写入磁盘）。当缓存内未写入磁盘数据量低于stop flush value时，flushing过程停止。控制器总是先flush旧的缓存数据。缓存内未写入数据停留超过20秒钟后被自动flushing. 典型的start flushing level是80%。通常情况下，stop flushing level也设置为80%。也就是说，控制器不允许超过80%的缓存用于write-back cache,但还是尽可能保持这一比例。如果你使用此设置，可以在缓存内存更多的未写入数据。这有利于提高写操作的性能，但是要牺牲数据保护。如果要得到数据保护，你可以使用较低的start and stop values。通过对这两个参数的设置，你可以调整缓存的读、写性能。经测试表明，使用接近的start and stop flushing levels时性能较好。如果stop level value远远低于start value，在flushing时会导致磁盘拥塞。 Cache block size 这个值指缓存分配单元大小，可以是4K或16K。选择合适的值，可以明显的改善缓存使用性能。 如果应用程序更多时候访问小于8K的数据，而将cache block size设置为16K，每次访问仅使用一部分cache block。在16K的cache block里总是存储8K或更小的数据，意味着只有50%的缓存容量被有效使用，使性能下降。对于随机I/O和小数据块的传送，4K比较合适。另一方面，如果是连续I/O 并使用大的segment size，最好选择16K。大的cache block size意味着cache block数量少并可缩短缓存消耗延时。另外，对于同样大小的数据，cache block size大一些，需要的缓存数据传送量更小。

 

 

其他相关说明：

 

保护内存里的数据

备援电池的功能是确保万一当主电源故障或突然断电时内存里的数据不流失，因此如何确保备援电池的正常运行就显得格外重要。备援电池在2种情况下，系统视为无法正常运行以保护内存里的数据。一是坏掉的时候，背板的LED灯将亮起红灯。一是电池充电的时候，背板的LED灯将亮起黄灯。备援电池的使用寿命是根据充电的次数及电力释放的周期而变化的，这取决于用户本身对盘阵的使用情况，一般而言我们建议最好在盘阵使用了12个月之后更换备援电池模块（BBU）。备援电池在正常情况下充满电的时候是3.5V，当其电力降至2.7V的时候将自动进入充电状态，此时系统因为保护内存数据不流失的电力消失，自动地将数据的写入切换成“Write-Through”模式；当充完电后，又自动切换回“Write-Back”模式。这个动作是在事件启动装置（Event Trigger）功能来执行的，在安装管理软件的时候，事件启动装置对备援电池的管理初始值是打开的（Enable）。如果你没有更改过初始设置，那么上述的动作就会正常的运行。如果备援电池已经坏掉，不能正常保护内存里的数据时，而事件启动装置对备援电池的管理是设定在关闭的状态下，我们建议你手动将数据写入模式更改为“Write-Through”模式，以免数据写入没有电力保护的内存中而主电源故障或突然断电时，这些正在写入的数据就遗失了。

 

减少延迟 当关闭内存“Write-Back”功能时就进入了“Write-Through”的模式，这时候主机数据是不会写入内存而直接写入硬盘的。在“Write-Through”模式下，所有的硬盘将与其相关的主机以适当的方式存取数据块，而大多数的时候硬盘处于接受写命令的状态。此时盘阵只要从主机接收到写入的命令，硬盘的读写头就会去寻找读写的位置，并等待硬盘处于可写入的状态，这个等待的现象就是所谓的延迟（Latency Time)，而硬盘经常处于等待写入的状态，增加了延迟的时间，不但缩短硬盘的使用寿命，并且系统也比较耗电。当打开内存的“Write-Back”功能时，从主机写入硬盘的数据先被写在内存里，在内存写满数据时盘阵控制器会将存在于内存的数据大量地写入硬盘。这个内存“Write-Back”的模式将主机写入的命令以写入内存来取代，可以大幅减少硬盘延迟的时间，并且相较于“Write-Through”模式，在大多数的时候提供更佳的写入政策。


附上安装方法

```bash
# https://docs.broadcom.com/docs/12351587
# wget http://docs.avagotech.com/docs-and-downloads/raid-controllers/raid-controllers-common-files/8-07-14_MegaCLI.zip
wget https://docs.broadcom.com/docs-and-downloads/raid-controllers/raid-controllers-common-files/8-07-14_MegaCLI.zip
unzip 8-07-14_MegaCLI.zip
cd Linux
rpm -ivh MegaCli-8.07.14-1.noarch.rpm
ls /opt/MegaRAID/MegaCli/           
CmdTool.log  install.log  libstorelibir-2.so  libstorelibir-2.so.14.07-0  MegaCli64  MegaSAS.log
chmod -R * +x /opt/MegaRAID
```


raid更换硬盘查看同步进度
```bash
./MegaCli64 -PDlist -aAll | grep -E "Slot|state:|ID:"

[root@zhenru1-197 MegaCli]# ./MegaCli64 -PDlist -aAll | grep -E "Slot|state:|ID:"
Enclosure Device ID: 32
Slot Number: 0
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 1
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 2
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 3
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 4
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 5
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 6
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 7
Firmware state: Online, Spun Up
[root@zhenru1-197 MegaCli]# 


./MegaCli64 -PDRbld -ShowProg -PhysDrv [32:3] -a0
#32即Enclosure Device ID，3即Slot Number



[root@zhenru1-197 MegaCli]# ./MegaCli64 -PDlist -aAll | grep -E "Slot|state:|ID:"
Enclosure Device ID: 32
Slot Number: 0
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 1
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 2
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 3
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 4
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 5
Firmware state: Online, Spun Up
Enclosure Device ID: 32
Slot Number: 6
Firmware state: Rebuild
Enclosure Device ID: 32
Slot Number: 7
Firmware state: Online, Spun Up
[root@zhenru1-197 MegaCli]# 
[root@zhenru1-197 MegaCli]# 
[root@zhenru1-197 MegaCli]# 
[root@zhenru1-197 MegaCli]# ./MegaCli64 -PDRbld -ShowProg -PhysDrv [32:6] -a0 
                                     
Rebuild Progress on Device at Enclosure 32, Slot 6 Completed 5% in 1 Minutes.

Exit Code: 0x00
[root@zhenru1-197 MegaCli]# 
```


  [1]: http://r.loli.io/VnUZ7n.png
  [2]: http://r.loli.io/Yj6Zbm.png
  [3]: http://r.loli.io/vYj2ye.png
  [4]: http://r.loli.io/BniYFf.png
  [5]: http://r.loli.io/y67vYf.png
  [6]: http://r.loli.io/2mU3Yb.png
  [7]: http://r.loli.io/BZRNRf.jpg
  [8]: http://r.loli.io/2uYfMf.png
