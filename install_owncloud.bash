#!/bin/bash

# Menampilkan pesan selamat datang dan meminta input URL kustom
echo "Selamat datang di Instalasi OwnCloud!"
read -p "Masukkan URL kustom untuk konfigurasi (misalnya: cloud.example.com): " custom_url

# Memperbarui dan menginstal semua paket yang dibutuhkan
apt-get update
apt install apache2 mariadb-server -y
apt install php7.4 libapache2-mod-php7.4 php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} -y
apt install curl gnupg2 -y
add-apt-repository ppa:ondrej/php --yes &> /dev/null
apt update
apt install php7.4 php7.4-mysql php-pear -y

# Menambahkan repository dan menginstal OwnCloud
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10.9.1/Ubuntu_22.04/ /' > /etc/apt/sources.l>
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:/10/Ubuntu_20.04/Release.key | gpg --dearmor >
apt update
apt install owncloud-complete-files -y

# Membuat direktori OwnCloud
mkdir -p /var/www/owncloud

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
EOL# Mengaktifkan konfigurasi Apache dan restart service
a2ensite owncloud.conf
a2enmod rewrite
systemctl restart apache2

# Konfigurasi database MySQL untuk OwnCloud
mysql --password=1234 --user=root --host=localhost << EOF
CREATE DATABASE ownclouddb;
GRANT ALL PRIVILEGES ON ownclouddb.* TO 'root'@'localhost' IDENTIFIED BY '1234';
FLUSH PRIVILEGES;
EOF

# Menjalankan instalasi OwnCloud
sudo -u www-data php /var/www/owncloud/occ maintenance:install \
   --database "mysql" \
   --database-name "ownclouddb" \
   --database-user "root" \
   --database-pass "1234" \
   --admin-user "root" \
   --admin-pass "1234"

echo "Instalasi OwnCloud selesai! Anda dapat menjalankannya dengan memasukkan URL baru kapanpuns."
