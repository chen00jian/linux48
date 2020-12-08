---
title: Repair Cisco vpnclient on windows10
date: 2015-08-03
tags:
- cisco
- vpn
- windows10
categories:
 - System
---


::: tip
由于此问题是windows10刚发布，但是cisco单方面并没有及时修复，并且就目前看来是全球的工程师都碰到的一个很紧急棘手的问题
在查找修复方案的时候;得到好多歪果仁的帮助，特地写了一片洋文，希望可以帮到更多的人，蹩脚的E文如有问题请留言或者邮件我及时勘误，不甚感激！
:::

<!-- more -->


## fyi

由于此问题是windows10刚发布，但是cisco单方面并没有及时修复，并且就目前看来是全球的工程师都碰到的一个很紧急棘手的问题

在查找修复方案的时候;得到好多歪果仁的帮助，特地写了一片洋文，希望可以帮到更多的人，蹩脚的E文如有问题请留言或者邮件我及时勘误，不甚感激！


Microsoft released last week by the windows10, after the upgrade `vpnclient-winx64-msi-5.0.07.0440-k9.exe` found this installation as wrong.

![][1]

First we first fix, so that vpnclient-winx64-msi-5.0.07.0440-k9.exe is properly installed


------------------------------------------

## Fix Install Error

Download the 2 software **``winfix.exe``** and **``dneupdate64.msi``**

first install **``winfix.exe``** 

and then install **``dneupdate64.msi``**

and finally extract the **``vpnclient-winx64-msi-5.0.07.0440-k9.exe``**, and execute the installation file **``vpnclient_setup.exe``**

Now Cisco VPN clients has been successfully installed on windows10 ！

------------------------------------------

## Fix Dialing Error

But, the back of the account password when I dial the wrong

``Secure VPN Connection terminated locally by the Client.``
``Reason 433: Reason not specified by peer.``

Continue to search for information to fix this funking problem ！！！

The likely reason was apparently due to the DNE LightWeight Filter network client not being properly installed by the Cisco Systems VPN installer.

To solve this, please try to do the following in the exact order:

A) First, uninstall any Cisco VPN Client software you may have installed earlier;

B) Then uninstall any DNE updater software(s) you may have installed earlier;

C) Reboot your computer.

D) Run winfix.exe, to ensure the DNE is properly cleaned up. 

E) Reboot your computer again.

F) Download Sonic VPN software from here: 32-bit here or 64-bit here.

G) Install the Sonic VPN software (which was able to install the right version of the DNE);

H) Reboot your computer.

I) Reinstall the Cisco VPN Client software again. (You do not need to uninstall the Sonic VPN software from step G). If you face a version check issue, run the msi file instead of the exe file

J) Reboot your computer.

K) Your Cisco VPN Client should now work in Windows 10!

Finally we dial again, what the funking！！ reporting error again ！！

``vpn 422 failed to enable virtual adapter``

------------------------------------------

## Finally Fix this problem

Enter the registry regedit

``HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CVirtA`` find ``DisplayName``  key  

Value of X86 system change **`@oem16.inf,%CVirtA_Desc%;Cisco Systems VPN Adapter`** to **`Cisco Systems VPN Adapter`**

Value of 64 system change **`@oem16.inf,%CVirtA_Desc%;Cisco Systems VPN Adapter for 64-bit Windows`** to **`Cisco Systems VPN Adapter for 64-bit Windows`**

And then landed on the dial, success!!
Now the problem of the egg pain is completely solved!!!

------------------------------------------

bove software download address

for 64bit
[ftp://files.citrix.com/winfix.exe][2]
[ftp://files.citrix.com/dneupdate64.msi][3]
http://www.gleescape.com/wp-content/uploads/2014/09/sonic64.zip

for 32bit
[ftp://files.citrix.com/winfix.exe][2]
[ftp://ftpsupport.citrix.com/dneupdate.msi][4]
http://www.gleescape.com/wp-content/uploads/2014/09/sonic32.zip

Chinese users may download speed will be very slow, I deliberately uploaded to Baidu cloud

http://pan.baidu.com/s/1o6vcMz4

Reference website:
http://www.itsystemadmin.com/error-27850-unable-to-manage-networking-component/
http://www.gleescape.com/posts/2917
http://blog.itpub.net/9697/viewspace-1437036/

Thanks them very much!!!


  [1]: http://r.loli.io/eAVbii.png
  [2]: ftp://files.citrix.com/winfix.exe
  [3]: ftp://files.citrix.com/dneupdate64.msi
  [4]: ftp://ftpsupport.citrix.com/dneupdate.msi
