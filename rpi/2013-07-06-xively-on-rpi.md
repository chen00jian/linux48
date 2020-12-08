---
title: 利用xively监控Raspberry Pi的Load和温度
date: 2013-07-06
tags:
- RaspberryPi
categories:
 - RaspberryPi
---




##xively账户准备

1.[注册账户](https://xively.com/signup/)

2.添加一个设备

菜单上develop， 然后点击Add Device

![mahua](https://i.loli.net/2019/10/16/QK5ZXcSroiRVGj1.jpg)

提交后会得到Feed ID，Feed URL，API Endpoint相关信息，后续API使用要用。


![mahua](https://i.loli.net/2019/10/16/UWy1e9Ao5Fakhrt.jpg)

##准备SHELL打点脚本

```bash
mkdir /home/pi/sysdata/

cd /home/pi/sysdata/

vi xively.sh

#!/bin/bash
LOCATION='/home/pi/sysdata'   #生成JSON文件路径,替换成你的路径
API_KEY='l9eHDf_fLzQx9Qfc8hCVrIan9DOSAKxrN21EOTdyL1IxST0g' #API使用的KEY,替换成你的KEY
FEED_ID='126908' #提交数据的FEED,替换成你的FEED_ID
####################################################
COSM_URL=https://api.xively.com/v2/feeds/${FEED_ID}?timezone=+8
cpu_load=`cat /proc/loadavg | awk '{print $2}'`
for i in 1 2 3 4 5; do
        cpu_t=`cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000}'`
        if [[ "${cpu_t}" =~ ^- ]]
        then
                cpu_t='0.0'
        else
                echo ${cpu_t}
                break
        fi
done
STR=`awk 'BEGIN{printf "{\"datastreams\":[ {\"id\":\"load\",\"current_value\":\"%.2f\"}, {\"id\":\"temp\",\"current_value\":\"%.2f\"}] } ",'$cpu_load','$cpu_t'}'`
echo ${cpu_t}
echo ${cpu_load}
echo ${STR}
echo ${STR} > ${LOCATION}/cosm.json
curl -s -v --request PUT --header "X-ApiKey: ${API_KEY}" --data-binary @${LOCATION}/cosm.json ${COSM_URL}
```

修改脚本中需要替换成你自己的三个变量LOCATION，API_KEY，FEED_ID 之后 赋予改脚本文件 755权限并且运行。

``sudo chmod 777 xively.sh``

加入crontab每一分钟执行一次

```bash
vi /etc/crontab

*/1 * * * *   root  /home/pi/sysdata/xively.sh  >>  /home/pi/sysdata/xively.log  2>&1
```

##页面引入图表

在需要暂时图表的地方加入以下代码：

    <img src="https://api.xively.com/v2/feeds/${FEED_ID}/datastreams/${LINE_ID}.png?width=340&height=180&colour=%23f15a24&duration=2days&title=${TITLE}&show_axis_labels=false&detailed_grid=true&scale=&timezone=8"/>
    
${FEED_ID}:替换成你创建FEED的ID，上个例子中就是126908

${LINE_ID}:替换成你FEED里具体LINE的ID，上个例子中就是load或者temp

${TITLE} :图表展示上的标题,可以自己按照需要命名，比如CPU的LOAD

 
 
##下面是我的树莓派温度监控效果

![mahua](https://api.xively.com/v2/feeds/1974048517/datastreams/temp.png?width=340&height=180&colour=%23f15a24&duration=2days&title=%E6%A0%91%E8%8E%93%E6%B4%BECPU%E6%B8%A9%E5%BA%A6&show_axis_labels=false&detailed_grid=true&scale=&timezone=8)

![mahua](https://api.xively.com/v2/feeds/1974048517/datastreams/load.png?width=340&height=180&colour=%23f15a24&duration=2days&title=%E6%A0%91%E8%8E%93%E6%B4%BECPU%20Load&show_axis_labels=false&detailed_grid=true&scale=&timezone=8)

参考大神连接 http://dqylyln.dyndns.org/2013/use-cosm.html#comment-952442797
