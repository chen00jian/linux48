---
title: SFTP+ChrootDirectory设置
date: 2015-09-23
tags:
- chroot
- sftp
categories:
 - System
---

```bash

vim /etc/ssh/sshd_config

# override default of no subsystems
#Subsystem      sftp    /usr/libexec/openssh/sftp-server

         Subsystem       sftp    internal-sftp

         Match Group sftpusers

         ChrootDirectory /home/sftpusers/home/%u
         X11Forwarding no
         AllowTcpForwarding no
         ForceCommand internal-sftp

# Example of overriding settings on a per-user basis

/etc/init.d/sshd restart



useradd -d  /home/sftpusers/home/pizzahut  -g   sftpusers -s  /bin/false  pizzahut
passwd pizzahut

cd  /home/sftpusers/home/
chown root.root pizzahut
chmod 755 pizzahut
cd  /home/sftpusers/home/pizzahut
mkdir ftp
chown pizzahut.sftpusers ftp
chmod 775 ftp



sftp -oPort=22 pizzahut@ip
```

