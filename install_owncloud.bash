#!/bin/bash    

# Menampilkan logo dan pesan selamat datang
showMe    
echo "Selamat datang di Instalasi OwnCloud!"
sleep 2s

# Memperbarui sistem dan menginstal paket yang diperlukan
apt update && apt upgrade -y
apt install apache2 mariadb-server php7.4 libapache2-mod-php7.4 \
php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} curl gnupg2 -y

# Menambahkan repository OwnCloud dan menginstal OwnCloud
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10.9.1/Ubuntu_22.04/ /' > /etc/apt/sources.list.d/owncloud.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:/10/Ubuntu_20.04/Release.key | gpg --dearmor > /etc/apt/trusted.gpg.d/owncloud.gpg
apt update
apt install owncloud-complete-files -y

# Membuat direktori OwnCloud dan memberikan izin
mkdir -p /var/www/owncloud
chown -R www-data:www-data /var/www/owncloud

# Konfigurasi database MySQL
mysql --user=root << EOF
CREATE DATABASE IF NOT EXISTS ownclouddb;
GRANT ALL PRIVILEGES ON ownclouddb.* TO 'ownclouduser'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EOF

# Menjalankan instalasi OwnCloud melalui CLI
sudo -u www-data php /var/www/owncloud/occ maintenance:install \
   --database "mysql" \
   --database-name "ownclouddb" \
   --database-user "ownclouduser" \
   --database-pass "password" \
   --admin-user "admin" \
   --admin-pass "admin"

# Menampilkan pesan selesai
echo "Instalasi OwnCloud selesai! Anda dapat menjalankan OwnCloud dengan URL yang Anda inginkan."
