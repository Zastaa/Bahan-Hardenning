#!/bin/bash

cd /usr/local/src

wget https://snort.org/downloads/snort/snort-openappid-2.9.20-1.centos.x86_64.rpm

yum install snort-openappid-2.9.20-1.centos.x86_64.rpm -y

sudo ln -s /usr/lib64/libdnet.so /usr/lib64/libdnet.1

mkdir /usr/local/lib/snort_dynamicrules

sed -i '/include $RULE_PATH\/local.rules/a include rules/sqli.rules' /etc/snort/snort.conf #untuk menambahkan rule file sqli
sed -i '/include $RULE_PATH\/local.rules/a include rules/xss.rules' /etc/snort/snort.conf #untuk menambahkan rule file xss
sed -i '/include $RULE_PATH\/local.rules/a include rules/ssh.rules' /etc/snort/snort.conf #untuk menambahkan rule file ssh
sed -i '511,512 s/^/#/' /etc/snort/snort.conf #comment whitelisting dan blacklisting
sed -i '546 s/^/#/' /etc/snort/snort.conf #comment baris untuk local.rules
sed -i '551,654 s/^/#/' /etc/snort/snort.conf #comment banyak baris rules

cat << ruleSqli > /etc/snort/rules/sqli.rules
alert tcp any any -> any 80 (msg: "Error Based SQL Injection Detected"; content: "%27" ; sid:100000011; )
alert tcp any any -> any 80 (msg: "Error Based SQL Injection Detected"; content: "%22" ; sid:100000012; )
alert tcp any any -> any 80 (msg: "AND SQL Injection Detected"; content: "and" ; nocase; sid:100000060; )
alert tcp any any -> any 80 (msg: "OR SQL Injection Detected"; content: "or" ; http_uri; nocase; sid:100000061; )
ruleSqli

cat << ruleSsh > /etc/snort/rules/ssh.rules
alert tcp any any -> any 22 (msg: "SSH Bruteforce Attack Detected"; flags: S+;  threshold: type both, track by_src, count 15, seconds 5; sid:10000404; rev:1;)
ruleSsh

cat << ruleXss > /etc/snort/rules/xss.rules
alert tcp any any -> any 80 (msg: "XSS attack - Detected <script></script>"; content: "<script>"; http_uri; content: "</script>"; http_uri; sid: 10000301; rev:1;)
ruleXss

snort -T -i enp0s3 -c /etc/snort/snort.conf #testing
snort -D -i enp0s3 -c /etc/snort/snort.conf -l /var/log/snort #running snort on the background dan menyimpan lognya
