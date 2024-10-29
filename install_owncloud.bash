#!/bin/bash

# Menampilkan pesan selamat datang dan meminta input URL kustom
echo "Selamat datang di Instalasi OwnCloud! By PUTRA"
read -p "Masukkan URL kustom untuk konfigurasi (misalnya: putraganteng.com): " custom_url

# Memperbarui dan menginstal semua paket yang dibutuhkan
apt-get update
apt-get install -y apache2 mariadb-server \
  php7.4 libapache2-mod-php7.4 php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} \
  curl gnupg2 software-properties-common

add-apt-repository ppa:ondrej/php --yes &> /dev/null
apt-get update
apt-get install -y php7.4 php7.4-mysql php-pear

# Menambahkan repository dan menginstal OwnCloud
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10.9.1/Ubuntu_22.04/ /' > /etc/apt/sources.list.d/owncloud.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:/10/Ubuntu_20.04/Release.key | gpg --dearmor -o /usr/share/keyrings/owncloud.key
apt-get update
apt-get install -y owncloud-complete-files

# Membuat direktori OwnCloud
mkdir -p /var/www/owncloud
chown -R www-data:www-data /var/www/owncloud
chmod -R 755 /var/www/owncloud

# Membuat file konfigurasi Apache dengan URL yang dimasukkan
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
mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ownclouddb;
GRANT ALL PRIVILEGES ON ownclouddb.* TO 'ownclouduser'@'localhost' IDENTIFIED BY 'owncloudpass';
FLUSH PRIVILEGES;
EOF

# Menjalankan instalasi OwnCloud
sudo -u www-data php /var/www/owncloud/occ maintenance:install \
   --database "mysql" \
   --database-name "ownclouddb" \
   --database-user "ownclouduser" \
   --database-pass "owncloudpass" \
   --admin-user "admin" \
   --admin-pass "adminpassword"

echo "Instalasi OwnCloud selesai! Anda dapat mengaksesnya di http://$custom_url"
