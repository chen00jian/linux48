---
title: OCR之Tesseract的linux下安装
date: 2012-05-17
tags:
- OCR
- Tesseract
categories:
 - System
---




今天应公司要求需要转换扫描出来的电子书jpg格式到文本格式需要，找了很多转换工具大都不进入人意，后来同事给我介绍tesseract。

后来了解了一下此软件


光学字符识别(OCR,Optical Character Recognition)是指对文本资料进行扫描，然后对图像文件进行分析处理，获取文字及版面信息的过程。OCR技术非常专业，一般多是印刷、打印行业的从业人员使用，可以快速的将纸质资料转换为电子资料。项目源码可从http://code.google.com/p/tesseract-ocr/downloads/list获得


关于windows下的安装网上有很多教程如此篇<http://www.cnblogs.com/brooks-dotnet/archive/2010/10/05/1844203.html>

下面我写一下linux下的安装教程以供参考！

* * *

准备工作:

编译环境: gcc gcc-c++ make 这个环境一般机器都具备,可以忽略,若果没有可以用下面yum安装一下

	yum install gcc gcc-c++ make

安装需要的赖的包: autoconf automake libtool libjpeg-devel libpng-devel libtiff-devel zlib-devel leptonica(1.67以上)



##1. autoconf automake libtool libjpeg-devel libpng-devel libtiff-devel zlib-devel 可以通过yum安装:**

	yum install autoconf automake libtool
	yum install libjpeg-devel libpng-devel libtiff-devel zlib-devel



##2. leptonica 需要源码编译安装**  

下载 leptonica 包，解压后切换到 leptonica-1.68 根目录  

```bash
wget http://www.leptonica.org/source/leptonica-1.68.tar.gz
cd leptonica-1.68
./configure
make
make install
```

##3.tesseract安装:

依赖包安装完毕后开始安装tesseract  
下载 tesseract-3.01 安装包,解压后切换到 tesseract-3.01 根目录  

```bash
wget http://tesseract-ocr.googlecode.com/files/tesseract-3.01.tar.gz
cd tesseract-3.01
./autogen.sh
./configure
make
make install
ldconfig
```


友情提示：如果在make时遇到类似 strngs.h:1: error: stray &#8216;\357&#8242; in program 的错误，请将 tesseract-3.01/ccutil/strngs.h 文件转为 ANSI 编码保存,再重新编译！关于转码问题清参考此文http://blog.csdn.net/zhuying_linux/article/details/7084518


##4.语言包安装 
tesseract英文语言包安装:  
下载 tesseract-3.01 英文语言包  
解压后将 tesseract-ocr/tessdata 下的所有文件全部拷贝到 /usr/local/share/tessdata 下  

    wget http://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.01.eng.tar.gz
	tar zxvf tesseract-ocr-3.01.eng.tar.gz<br />
	cp tesseract-ocr/tessdata /usr/local/share/tessdata`

tesseract中文语言包安装:

点此下载[chi_sim.traineddata.gz][1]解压后将chi_sim.traineddata拷贝到 /usr/local/share/tessdata下

至此安装完毕，下面开始验证一下！

转英文文档的方法：  
切换到解压后的 tesseract-3.01 根目录(这个目录下有一个自带的 phototest.tif 可以做测试用)  
输入  

	tesseract phototest.tif phototest -l eng

可以看到输出如下信息  

	Tesseract Open Source OCR Engine v3.01 with Leptonica
	Page 0
 
这时应该在当前目录生成一个 phototest.txt 文本文件,内容就是 phototest.tif 显示的文字.

转中文文档的方法：  
上传要转换的中文文档图片到/tesseract-3.01目录下  
输入  

	tesseract chi.tif chi -l chi_sim

此时当前目录就会有一个chi.txt的文本文件，内容就是chi.tif显示的中文文字。（不过此中文语言包最后更新是2010年效果实在是差强人意，不知道以后会不会更新）

这里注意命令的格式：图片名称要加上扩展名.tif，输出文件和语言包不需要加扩展名。