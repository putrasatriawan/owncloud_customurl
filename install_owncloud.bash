#!/bin/bash

# Fungsi untuk menampilkan banner dan pesan
showBanner() {
  echo "============================================="
  echo "        🚀 Selamat Datang di Instalasi OwnCloud! 🚀"
  echo "              By Putra - Cloud Enthusiast"
  echo "============================================="
  echo ""
}

# Menampilkan banner selamat datang
showBanner

# Meminta input URL kustom dari pengguna
read -p "🌐 Masukkan URL kustom untuk konfigurasi (misalnya: cloud.example.com): " custom_url

# Memperbarui dan menginstal semua paket yang dibutuhkan
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

# Membuat file konfigurasi Apache
echo "⚙️ Membuat konfigurasi Apache dengan URL: $custom_url"
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

# Mengaktifkan konfigurasi Apache dan restart service
echo "🔄 Mengaktifkan konfigurasi Apache dan restart service..."
sudo a2ensite owncloud.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Konfigurasi database MySQL untuk OwnCloud
echo "🛠️ Konfigurasi database MySQL..."
sudo mysql --password=1234 --user=root --host=localhost << EOF
CREATE DATABASE ownclouddb;
GRANT ALL PRIVILEGES ON ownclouddb.* TO 'root'@'localhost' IDENTIFIED BY '1234';
FLUSH PRIVILEGES;
EOF

# Menjalankan instalasi OwnCloud melalui CLI
echo "🚀 Menjalankan instalasi OwnCloud..."
sudo -u www-data php /var/www/owncloud/occ maintenance:install \
   --database "mysql" \
   --database-name "ownclouddb" \
   --database-user "root" \
   --database-pass "1234" \
   --admin-user "root" \
   --admin-pass "1234"

# Pesan akhir
echo "🎉 Instalasi OwnCloud selesai!"
echo "🌐 Akses OwnCloud melalui: http://$custom_url"
echo "⚡ Anda dapat menjalankannya dengan memasukkan URL baru kapanpun."
echo "============================================="
echo "            By Putra - Cloud Enthusiast"
echo "============================================="
