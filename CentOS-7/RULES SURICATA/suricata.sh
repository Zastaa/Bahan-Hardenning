#!/bin/bash

sed -i 's/eth0/enp0s3/g' /etc/sysconfig/suricata
sed -i 's/eth0/enp0s3/g' /etc/suricata/suricata.yaml
sed -i '/- suricata.rules/a\  - sqli.rules' /etc/suricata/suricata.yaml
sed -i '/- suricata.rules/a\  - xss.rules' /etc/suricata/suricata.yaml
sed -i '/- suricata.rules/a\  - ssh.rules' /etc/suricata/suricata.yaml

echo '
alert tcp any any -> any 80 (msg: "Error Based SQL Injection Detected"; content: "%27" ; sid:100000011; )
alert tcp any any -> any 80 (msg: "Error Based SQL Injection Detected"; content: "%22" ; sid:100000012; )
alert tcp any any -> any 80 (msg: "AND SQL Injection Detected"; content: "and" ; nocase; sid:100000060; )
alert tcp any any -> any 80 (msg: "OR SQL Injection Detected"; content: "or" ; http_uri; nocase; sid:100000061; )
' >> /etc/suricata/rules/sqli.rules
echo 'alert tcp any any -> any 22 (msg: "SSH Bruteforce Attack Detected"; flags: S+;  threshold: type both, track by_src, count 15, seconds 5; sid:10000404; rev:1;)' >> /etc/suricata/rules/ssh.rules

echo 'alert tcp any any -> any 80 (msg: "XSS attack - Detected <script></script>"; content: "<script>"; http_uri; content: "</script>"; http_uri; sid: 10000301; rev:1;)' >> /etc/suricata/rules/xss.rules


systemctl restart suricata
