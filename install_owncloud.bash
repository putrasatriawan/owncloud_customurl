#!/bin/bash



# Menampilkan logo dan pesan selamat datang
showMe
echo "Selamat datang di Instalasi OwnCloud!"
sleep 2s

# Meminta URL kustom dari pengguna
read -p "Masukkan URL kustom untuk OwnCloud (misalnya: cloud.example.com): " custom_url

# Memperbarui dan menginstal paket yang diperlukan
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 mariadb-server php7.4 libapache2-mod-php7.4 \
php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} curl gnupg2 -y

# Menambahkan repository OwnCloud dan menginstalnya
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10.9.1/Ubuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/owncloud.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:/10/Ubuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/owncloud.gpg > /dev/null
sudo apt update
sudo apt install owncloud-complete-files -y

# Membuat direktori OwnCloud dan memberikan izin
sudo mkdir -p /var/www/owncloud
sudo chown -R www-data:www-data /var/www/owncloud
sudo chmod -R 755 /var/www/owncloud

# Konfigurasi database MySQL
sudo mysql --user=root << EOF
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

# Menghapus semua entri trusted_domains dan menambahkan yang baru
sudo sed -i "/'trusted_domains' =>/,/),/d" /var/www/owncloud/config/config.php
sudo sed -i "/);/i\  'trusted_domains' => array (\n    0 => 'localhost',\n    1 => '$custom_url',\n  )," /var/www/owncloud/config/config.php

# Membuat konfigurasi Apache dengan URL kustom
sudo tee /etc/apache2/sites-available/owncloud.conf > /dev/null << EOL
<VirtualHost *:80>
  ServerName $custom_url
  DocumentRoot /var/www/owncloud

  <Directory /var/www/owncloud>
    Options +FollowSymlinks
    AllowOverride All
    Require all granted

    <IfModule mod_dav.c>
      Dav off
    </IfModule>

    SetEnv HOME /var/www/owncloud
    SetEnv HTTP_HOME /var/www/owncloud
  </Directory>

  ErrorLog \${APACHE_LOG_DIR}/owncloud_error.log
  CustomLog \${APACHE_LOG_DIR}/owncloud_access.log combined
</VirtualHost>
EOL

# Menonaktifkan konfigurasi default Apache dan mengaktifkan OwnCloud
sudo a2dissite 000-default.conf
sudo a2ensite owncloud.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Pesan akhir
echo "Instalasi OwnCloud selesai! OwnCloud sekarang dapat diakses melalui: http://$custom_url"
