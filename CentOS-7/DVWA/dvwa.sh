#!/bin/bash

cd /var/www/html

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=1194/udp --permanent
firewall-cmd --add-service=openvpn --permanent
firewall-cmd --add-service=http --permanent
firewall-cmd --remove-service=dhcpv6-client --permanent
firewall-cmd --remove-service=cockpit --permanent
firewall-cmd --reload

git clone https://github.com/digininja/DVWA.git

systemctl restart mariadb
systemctl enable --now mariadb

mysql -u root -e "create database dvwa"
mysql -u root -e "create user 'kampak'@'localhost' identified by 'kampak123'"
mysql -u root -e "grant all on dvwa.* to 'kampak'@'localhost'"
mysql -u root -e "flush privileges"

setsebool -P httpd_can_network_connect_db 1

cat << EOF > DVWA/config/config.inc.php
<?php

# If you are having problems connecting to the MySQL database and all of the variables below are correct
# try changing the 'db_server' variable from localhost to 127.0.0.1. Fixes a problem due to sockets.
#   Thanks to @digininja for the fix.

# Database management system to use
\$DBMS = getenv('DBMS') ?: 'MySQL';
#\$DBMS = 'PGSQL'; // Currently disabled

# Database variables
#   WARNING: The database specified under db_database WILL BE ENTIRELY DELETED during setup.
#   Please use a database dedicated to DVWA.
#
# If you are using MariaDB then you cannot use root, you must use create a dedicated DVWA user.
#   See README.md for more information on this.
\$_DVWA = array();
\$_DVWA[ 'db_server' ]   = getenv('DB_SERVER') ?: '127.0.0.1';
\$_DVWA[ 'db_database' ] = getenv('DB_DATABASE') ?: 'dvwa';
\$_DVWA[ 'db_user' ]     = getenv('DB_USER') ?: 'kampak';
\$_DVWA[ 'db_password' ] = getenv('DB_PASSWORD') ?: 'kampak123';
\$_DVWA[ 'db_port']      = getenv('DB_PORT') ?: '3306';

# ReCAPTCHA settings
#   Used for the 'Insecure CAPTCHA' module
#   You'll need to generate your own keys at: https://www.google.com/recaptcha/admin
\$_DVWA[ 'recaptcha_public_key' ]  = getenv('RECAPTCHA_PUBLIC_KEY') ?: '';
\$_DVWA[ 'recaptcha_private_key' ] = getenv('RECAPTCHA_PRIVATE_KEY') ?: '';

# Default security level
#   Default value for the security level with each session.
#   The default is 'impossible'. You may wish to set this to either 'low', 'medium', 'high' or impossible'.
\$_DVWA[ 'default_security_level' ] = getenv('DEFAULT_SECURITY_LEVEL') ?: 'impossible';

# Default locale
#   Default locale for the help page shown with each session.
#   The default is 'en'. You may wish to set this to either 'en' or 'zh'.
\$_DVWA[ 'default_locale' ] = getenv('DEFAULT_LOCALE') ?: 'en';

# Disable authentication
#   Some tools don't like working with authentication and passing cookies around
#   so this setting lets you turn off authentication.
\$_DVWA[ 'disable_authentication' ] = getenv('DISABLE_AUTHENTICATION') ?: false;

define ('MYSQL', 'mysql');
define ('SQLITE', 'sqlite');

# SQLi DB Backend
#   Use this to switch the backend database used in the SQLi and Blind SQLi labs.
#   This does not affect the backend for any other services, just these two labs.
#   If you do not understand what this means, do not change it.
\$_DVWA['SQLI_DB'] = getenv('SQLI_DB') ?: MYSQL;
#\$_DVWA['SQLI_DB'] = SQLITE;
#\$_DVWA['SQLITE_DB'] = 'sqli.db';

?>
EOF

systemctl restart httpd
systemctl restart mariadb
