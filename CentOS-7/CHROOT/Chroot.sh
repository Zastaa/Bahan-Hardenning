#!/bin/bash

library64="libtinfo.so.5 libc.so.6 libdl.so.2 ld-linux-x86-64.so.2 libselinux.so.1 libcap.so.2 libacl.so.1 libpcre.so.1 libattr.so.1 libpthread.so.0"

while getopts "sdh" opt; do
  case $opt in
    s) library64="libtinfo.so.6 libc.so.6 ld-linux-x86-64.so.2 libselinux.so.1 libcap.so.2 libpcre2-8.so.0" ;;
    d) library64="libtinfo.so.5 libc.so.6 libdl.so.2 ld-linux-x86-64.so.2 libselinux.so.1 libcap.so.2 libacl.so.1 libpcre.so.1 libattr.so.1 libpthread.so.0" ;;
    h)
      echo "Yang Bener Bang pakainya, ada dua opsi -s dan -d"
      exit 0
      ;;
    ?)
      echo "Invalid Options BROWWW!"
      exit 1
      ;;
  esac
done

jailUser="jumbo"
jailSftpUser="sftp_user"
groupSftp="sftp_group"
pw="123"

useradd ${jailUser}
echo "${jailUser}:${pw}" | sudo chpasswd
groupadd ${groupSftp}
useradd ${jailSftpUser} -g ${groupSftp} -s /bin/false
echo "${jailSftpUser}:${pw}" | sudo chpasswd
usermod -aG ${groupSftp} ${jailSftpUser}

mkdir /jail
mkdir -p /jail/etc /jail/bin /jail/home/${jailUser}/sftp /jail/lib64
chown -R ${jailUser}:${jailUser} /jail/home/${jailUser}
chown -R :${groupSftp} /jail/home/${jailUser}/sftp
cp /etc/{bashrc,profile} /jail/etc/
cp /bin/{bash,ls,echo,mkdir,pwd} /jail/bin/
cp /lib64/{${library64}} /jail/lib64/

echo "PS1='${jailUser}@server $: '" >> /jail/etc/profile
echo "export PATH=/bin:/usr/bin:/sbin:/usr/sbin" >> /jail/etc/profile
echo "Banner /etc/banner" >> /etc/ssh/sshd_config
echo "Match User ${jailUser}" >> /etc/ssh/sshd_config
echo "ChrootDirectory /jail" >> /etc/ssh/sshd_config
echo "Match Group ${groupSftp}" >> /etc/ssh/sshd_config
echo "ChrootDirectory /jail" >> /etc/ssh/sshd_config
echo "ForceCommand internal-sftp" >> /etc/ssh/sshd_config
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
echo "X11Forwarding no" >> /etc/ssh/sshd_config
