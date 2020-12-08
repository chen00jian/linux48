---
title: 树莓派python监控get脚本
date: 2014-04-24
tags:
- RaspberryPi
- python
categories:
 - RaspberryPi
---


树莓派内置了一个传感器你可以用来获取树莓派的CPU和GPU温度。

具体参数如下

```bash
pi@raspberrypi ~ $ cat /sys/class/thermal/thermal_zone0/temp
38470
pi@raspberrypi ~ $ vcgencmd measure_temp
temp=38.5'C
```

根据这2个参数写一个python脚本可以在终端打印小派当前硬件的使用情况以及cpu和gpu温度的python脚本，后面可以设置计划任务，打点显示！比xively监控参数略多！

这对于保护你的设备非常有用，举个例子：你可以在树莓派温度过高的时候关掉它或者在温度过热的时候报警。

```bash
import os
import commands

#vcgencmd measure_temp
#cat /sys/class/thermal/thermal_zone0/temp


# Return CPU temperature as a character string                                      
def getCPUtemperature():
    res = os.popen('vcgencmd measure_temp').readline()
    return(res.replace("temp=","").replace("'C\n",""))

# Return GPU temperature as a character string
def get_gpu_temp():
    gpu_temp = commands.getoutput( '/opt/vc/bin/vcgencmd measure_temp' ).replace( 'temp=', '' ).replace( '\'C', '' )
    return  float(gpu_temp)
    # Uncomment the next line if you want the temp in Fahrenheit
    # return float(1.8* gpu_temp)+32


# Return RAM information (unit=kb) in a list                                       
# Index 0: total RAM                                                               
# Index 1: used RAM                                                                 
# Index 2: free RAM                                                                 
def getRAMinfo():
    p = os.popen('free')
    i = 0
    while 1:
        i = i + 1
        line = p.readline()
        if i==2:
            return(line.split()[1:4])

# Return % of CPU used by user as a character string                                
def getCPUuse():
    return(str(os.popen("top -n1 | awk '/Cpu\(s\):/ {print $2}'").readline().strip(\
)))

# Return information about disk space as a list (unit included)                     
# Index 0: total disk space                                                         
# Index 1: used disk space                                                         
# Index 2: remaining disk space                                                     
# Index 3: percentage of disk used                                                  
def getDiskSpace():
    p = os.popen("df -h /")
    i = 0
    while 1:
        i = i +1
        line = p.readline()
        if i==2:
            return(line.split()[1:5])


# CPU informatiom
CPU_temp = getCPUtemperature()
CPU_usage = getCPUuse()

# RAM information
# Output is in kb, here I convert it in Mb for readability
RAM_stats = getRAMinfo()
RAM_total = round(int(RAM_stats[0]) / 1000,1)
RAM_used = round(int(RAM_stats[1]) / 1000,1)
RAM_free = round(int(RAM_stats[2]) / 1000,1)

# Disk information
DISK_stats = getDiskSpace()
DISK_total = DISK_stats[0]
DISK_used = DISK_stats[1]
DISK_perc = DISK_stats[3]

if __name__ == '__main__':
  print('')
  print('CPU Temperature = '+CPU_temp) , "C"
  print('CPU Use = '+CPU_usage)
  print "GPU Temperature = ", str(get_gpu_temp()), "C"
  print('')
  print('RAM Total = '+str(RAM_total)+' MB')
  print('RAM Used = '+str(RAM_used)+' MB')
  print('RAM Free = '+str(RAM_free)+' MB')
  print('')  
  print('DISK Total Space = '+str(DISK_total)+'B')
  print('DISK Used Space = '+str(DISK_used)+'B')
  print('DISK Used Percentage = '+str(DISK_perc))
```
    

执行效果

```bash
pi@raspberrypi ~ $ python /home/pi/sysdata/get.py

CPU Temperature = 34.5 C
CPU Use = 1.5
GPU Temperature =  34.5 C

RAM Total = 448.0 MB
RAM Used = 383.0 MB
RAM Free = 64.0 MB

DISK Total Space = 7.2GB
DISK Used Space = 2.1GB
DISK Used Percentage = 31%
```

