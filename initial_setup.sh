#!/bin/bash

# Install VBGuest additions on Ubuntu server. First script after fresh install.
# Script by Juan Miguel Expósito.
# v1.0

# To copy these files from local to the intended server using SSH use:
# scp * user@server:~


## To Do / Possible improvements:
# 1) Ask the user to confirm default variables in case they didn't change the script?
# 2) Use flag for defaults?
# 3) Consider in the future automating running the second script, probably by appending
#    the script execution to bashrc, and restoring the original as its first action.
# 4) I could integrate both stages in a single script and use maybe a temp file to signal
#    if it's the first or second stage. 
# 5) See about improving error handling.




############## SETUP ALL THE VARIABLES!!!
# VirtualBox
VBMOUNT=/vboxshare   # VirtualBox shared folder mount point inside the guest, as defined in the VM configuration.
VBSHARE=dev0         # Name of folder in the host that is being shared (if E:\VM\Share\Ubuntu, it'd be Ubuntu)
# Apache
SITE="sit0.dev0.lan" # First apache virtual host, needs to be actual domain or in hosts file of the client
# MySQL
MYSQL_ROOT_PASS="root" # Change to something else!
# PHPMyAdmin
PHPMYADMIN_PASS="root" # Change to something else!



############## First, take care of the shared folder.
cp /etc/fstab fstab.tmp
echo "$VBSHARE $VBMOUNT vboxsf rw,nodev,relatime,iocharset=utf8,uid=0,gid=998,dmode=0777,fmode=0777"  >> fstab.tmp
sudo cp /etc/fstab /etc/fstab.old
sudo mv fstab.tmp /etc/fstab
sudo mount $VBMOUNT




############## Start LAMP install



############## Apache install & basic dir setup
# Use figlet to display banners that are easy to find visually so the process less confusing.
figlet "Installing   Apache..."
sleep 2

mkdir $VBMOUNT/apache

sudo apt-get install -y apache2 apache2-utils

cp /var/www/html/index.html ~/i.tmp
sudo rm -rf /var/www
sudo ln -fs $VBMOUNT/apache /var/www
sudo mkdir /var/www/html
sudo mv ~/i.tmp /var/www/html/index.html

### Setup apache virtual hosts

SITE_PATH=/var/www/$SITE/public_html

mkdir -p $SITE_PATH

cat << __EOF__ > $SITE_PATH/index.html
<!DOCTYPE html>
<html>
  <body>
    <h1>$SITE Apache virtual host</h1>
  </body>
</html>
__EOF__


cat << __EOF__ > scfg.tmp
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName $SITE
    ServerAlias www.$SITE
    DocumentRoot $SITE_PATH
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
__EOF__

sudo mv scfg.tmp /etc/apache2/sites-available/$SITE.conf

figlet "Applying   configuration..."
sleep 2

sudo a2ensite $SITE.conf
sudo apache2ctl configtest
sudo systemctl restart apache2






############## Mysql install & config, root user, password "root"

figlet "Installing   MySQL..."
sleep 2

sudo apt-get install -y mysql-server

# configure authentication to use passwords

cat << __EOF__ > cfg.sql
SELECT user,authentication_string,plugin,host FROM mysql.user;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASS';
FLUSH PRIVILEGES;
SELECT user,authentication_string,plugin,host FROM mysql.user;
__EOF__

sudo mysql --execute "source cfg.sql"

rm cfg.sql







############## Install php

figlet "Installing   PHP..."
sleep 2

sudo apt-get install -y libapache2-mod-php7.4 php7.4-common php7.4-cli php-pear php7.4-curl php7.4-gd php7.4-gmp php7.4-intl php7.4-imap php7.4-json php7.4-ldap php7.4-mbstring php7.4-mysql php7.4-readline php7.4-soap php7.4-tidy php7.4-xmlrpc php7.4-xsl php7.4-zip

cat << __EOF__ > dir.conf
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
__EOF__


sudo mv dir.conf /etc/apache2/mods-enabled/dir.conf

#service apache2 restart
sudo systemctl restart apache2








############## phpmyadmin

figlet "Installing   PHPMyAdmin..."
sleep 2

echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASS" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_PASS" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_PASS" | sudo debconf-set-selections

sudo apt-get install -y phpmyadmin










############## Other Dev tools

### Node.js
figlet "Installing   Node.js"
sleep 2

curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

### MongoDB
figlet "Installing   MongoDB"
sleep 2

sudo apt-get install -y mongodb-server


### Docker
figlet "Installing   Docker"
sleep 2

sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER


### Python pip
figlet "Installing   assorted tools"
sleep 2

sudo apt-get install -y python3-pip sqlite3 sqlite3-doc



############## Extras

figlet "Getting   extras..."
sleep 2

sudo add-apt-repository ppa:bashtop-monitor/bashtop
sudo apt-get update
 
sudo apt-get install -y mc ranger screenfetch neofetch mlocate htop cockpit lnav tldr shellcheck
sudo apt-get install -y wordgrinder w3m w3m-img nmap fortune-mod cowsay lolcat cmatrix
sudo apt-get install -y bashtop
sudo snap install ponysay

sudo updatedb

figlet "ALL   DONE!!!"
sleep 1

echo "We've configured VBox share, installed apache and configured a virtual host,"
echo "Installed MySQL, php7, phpmyadmin, node, mongodb, docker, python pip, sqlite3,"
echo "mc, ranger, screenfetch, neofetch, mlocate, htop, cockpit(:9090), lnav,"
echo "bashtop, tldr, shellcheck, wordgrinder, w3m (& w3m-img), nmap, fortune, cowsay,"
echo " lolcat, ponysay, cmatrix, wordgrinder"
echo
echo "Please reboot before using docker"
echo
figlet "Enjoy."

