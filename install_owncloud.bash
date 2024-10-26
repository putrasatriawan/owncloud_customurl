#!/bin/bash

# Fungsi untuk menampilkan banner dan pesan
showBanner() {
  echo "============================================="
  echo "        🚀 Instalasi OwnCloud Dimulai! 🚀"
  echo "             By Putra - Cloud Enthusiast"
  echo "============================================="
  echo ""
}

# Tampilkan banner
showBanner

# Meminta input URL kustom dari pengguna
read -p "🌐 Masukkan URL kustom untuk OwnCloud (misalnya: cloud.example.com): " custom_url

# Memperbarui dan menginstal semua paket yang diperlukan
echo "🔄 Memperbarui paket dan menginstal dependensi..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install apache2 mariadb-server -y
sudo apt install php7.4 libapache2-mod-php7.4 php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} -y
sudo apt install curl gnupg2 -y
sudo add-apt-repository ppa:ondrej/php --yes &> /dev/null
sudo apt update
sudo apt install php7.4 php7.4-mysql php-pear -y

# Menambahkan repository dan menginstal OwnCloud
echo "📥 Menambahkan repository dan menginstal OwnCloud..."
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10.9.1/Ubuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/owncloud.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:/10/Ubuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/owncloud.gpg > /dev/null
sudo apt update
sudo apt install owncloud-complete-files -y

# Membuat direktori OwnCloud dan memberikan izin
echo "📂 Membuat direktori OwnCloud dan memberikan izin..."
sudo mkdir -p /var/www/owncloud
sudo chown -R www-data:www-data /var/www/owncloud
sudo chmod -R 755 /var/www/owncloud

# Konfigurasi database MySQL untuk OwnCloud
echo "🛠️ Mengonfigurasi database MySQL..."
sudo mysql --user=root << EOF
CREATE DATABASE ownclouddb;
GRANT ALL PRIVILEGES ON ownclouddb.* TO 'root'@'localhost' IDENTIFIED BY '1234';
FLUSH PRIVILEGES;
EOF

# Menjalankan instalasi OwnCloud
echo "🚀 Menjalankan instalasi OwnCloud..."
sudo -u www-data php /var/www/owncloud/occ maintenance:install \
   --database "mysql" \
   --database-name "ownclouddb" \
   --database-user "root" \
   --database-pass "1234" \
   --admin-user "admin" \
   --admin-pass "1234"

# Membuat konfigurasi Apache dengan URL kustom
echo "🔧 Mengatur konfigurasi Apache dengan URL: $custom_url"
sudo tee /etc/apache2/sites-available/owncloud.conf > /dev/null << EOL
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

  ErrorLog \${APACHE_LOG_DIR}/owncloud_error.log
  CustomLog \${APACHE_LOG_DIR}/owncloud_access.log combined
</VirtualHost>
EOL

# Mengaktifkan konfigurasi dan merestart Apache
echo "🔄 Mengaktifkan konfigurasi Apache dan merestart layanan..."
sudo a2ensite owncloud.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Membuka konfigurasi untuk menambahkan trusted domain secara manual
echo "🛠️ Membuka konfigurasi untuk trusted domains..."
sudo nano /var/www/owncloud/config/config.php

echo "⚠️ Tambahkan URL berikut ke bagian 'trusted_domains':"
echo "----------------------------------------------------"
echo "
'trusted_domains' =>
array (
    0 => 'localhost',
    1 => '$custom_url',  # Tambahkan URL baru Anda di sini
),
"
echo "----------------------------------------------------"
echo "👉 Setelah selesai, simpan dan keluar dari editor (Ctrl + O, Enter, Ctrl + X)."
sleep 5s

# Pesan akhir
echo "🎉 Instalasi OwnCloud selesai!"
echo "🌐 Akses OwnCloud melalui: http://$custom_url"
echo "============================================="
echo "         By Putra - Cloud Enthusiast"
echo "============================================="
