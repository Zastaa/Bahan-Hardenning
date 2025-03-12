#!/bin/bash
jailUser=""
jailSftpUser=""
groupSftp=""
pw="123"
useradd ${jailUser}
echo "${jailUser}:${pw}" | sudo chpasswd
groupadd ${groupSftp}
useradd ${jailSftpUser} -g ${groupSftp} -s /bin/false
usermod -aG ${groupSftp} ${jailSftpUser}
mkdir /jail
mkdir -p /jail/etc /jail/bin /jail/home/${jailUser}/sftp /jail/lib64
chown -R ${jailUser}:${jailUser} /jail/home/${jailUser}
chown -R :${groupSftp} /jail/home/${jailUser}/sftp
cp /etc/{bashrc,profile} /jail/etc/
cp /bin/{bash,ls,echo,mkdir,pwd} /jail/bin/
cp /lib64/{libtinfo.so.5,libc.so.6,libdl.so.2,ld-linux-x86-64.so.2,libselinux.so.1,libcap.so.2,libacl.so.1,libpcre.so.1,libattr.so.1,libpthread.so.0} /jail/lib64/
echo "PS1='${jailUser}@server $: '" >> /jail/etc/profile
echo "export PATH=/bin:/usr/bin:/sbin:/usr/sbin" >> /jail/etc/profile