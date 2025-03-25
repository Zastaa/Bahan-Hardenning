#!/bin/bash

cd /var/www/html

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=1194/udp --permanent
firewall-cmd --add-service=openvpn --permanent
firewall-cmd --remove-service=dhcpv6-client --permanent
firewall-cmd --remove-service=cockpit --permanent
firewall-cmd --reload

git clone https://github.com/digininja/DVWA.git

mysql -u root -e "create database dvwa"
mysql -u root -e "create user 'kampak'@'localhost' identified by 'kampak123'"
mysql -u root -e "grant all on dvwa.* to 'kampak'@'localhost'"
mysql -u root -e "flush privileges"

setsebool -P httpd_can_network_connect_db 1

systemctl restart httpd
systemctl restart mariadb
