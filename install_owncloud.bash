#!/bin/bash

# Menampilkan pesan selamat datang dan meminta input URL kustom
echo "Selamat datang di Instalasi OwnCloud!"
read -p "Masukkan URL kustom untuk OwnCloud (misalnya: cloud.example.com): " custom_url

# Memperbarui sistem dan menginstal paket yang dibutuhkan
apt update && apt upgrade -y
apt install apache2 mariadb-server -y
apt install php libapache2-mod-php php-mysql php-intl php-curl php-json php-gd php-xml php-mbstring php-zip php-cli -y
apt install curl gnupg2 -y

# Menambahkan repository OwnCloud dan menginstalnya
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10.9.1/Ubuntu_22.04/ /' > /etc/apt/sources.list.d/owncloud.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:/10/Ubuntu_20.04/Release.key | gpg --dearmor > /etc/apt/trusted.gpg.d/owncloud.gpg
apt update
apt install owncloud-complete-files -y

# Membuat direktori OwnCloud
mkdir -p /var/www/owncloud

# Memberikan izin kepemilikan direktori
chown -R www-data:www-data /var/www/owncloud

# Membuat file konfigurasi Apache dengan URL kustom
cat > /etc/apache2/sites-available/owncloud.conf << EOL
<VirtualHost *:80>
  ServerName $custom_url
  DocumentRoot /var/www/owncloud/

  <Directory /var/www/owncloud/>
    Options +FollowSymlinks
    AllowOverride All
    Require all granted

    <IfModule mod_dav.c>
      Dav off
    </IfModule>

    SetEnv HOME /var/www/owncloud
    SetEnv HTTP_HOME /var/www/owncloud
  </Directory>

  ErrorLog \${APACHE_LOG_DIR}/error.log
  CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Mengaktifkan konfigurasi Apache dan restart service
a2ensite owncloud.conf
a2enmod rewrite
systemctl restart apache2

# Konfigurasi database MySQL untuk OwnCloud
mysql --user=root << EOF
CREATE DATABASE ownclouddb;
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

echo "Instalasi OwnCloud selesai! Anda dapat menjalankannya dengan memasukkan URL baru kapanpun."
