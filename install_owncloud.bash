#!/bin/bash

# Menampilkan pesan selamat datang
echo "===================================="
echo "   Selamat datang di Instalasi OwnCloud! By Putra"
echo "===================================="
sleep 2s

# Meminta input URL kustom dari pengguna
read -p "Masukkan URL kustom untuk OwnCloud (misalnya: putraganteng.com): " custom_url

# Memperbarui dan menginstal paket yang diperlukan
echo "🔄 Memperbarui dan menginstal paket yang diperlukan..."
sudo apt update && sudo apt upgrade -y
sudo apt install apache2 mariadb-server php7.4 libapache2-mod-php7.4 \
php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} curl gnupg2 -y

# Menambahkan repository OwnCloud dan menginstal OwnCloud
echo "🔄 Menambahkan repository dan menginstal OwnCloud..."
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10.9.1/Ubuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/owncloud.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:/10/Ubuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/owncloud.gpg > /dev/null
sudo apt update
sudo apt install owncloud-complete-files -y

# Membuat direktori OwnCloud dan memberikan izin
echo "🔧 Membuat direktori dan memberikan izin..."
sudo mkdir -p /var/www/owncloud
sudo chown -R www-data:www-data /var/www/owncloud
sudo chmod -R 755 /var/www/owncloud

# Konfigurasi database MySQL
echo "📦 Konfigurasi database MySQL..."
sudo mysql --user=root << EOF
CREATE DATABASE IF NOT EXISTS ownclouddb;
GRANT ALL PRIVILEGES ON ownclouddb.* TO 'ownclouduser'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EOF

# Menjalankan instalasi OwnCloud
echo "🚀 Menjalankan instalasi OwnCloud..."
sudo -u www-data php /var/www/owncloud/occ maintenance:install \
   --database "mysql" \
   --database-name "ownclouddb" \
   --database-user "ownclouduser" \
   --database-pass "password" \
   --admin-user "admin" \
   --admin-pass "admin"

# Backup konfigurasi sebelum perubahan
echo "📋 Membackup file konfigurasi..."
sudo cp /var/www/owncloud/config/config.php /var/www/owncloud/config/config.php.bak

# Menambahkan domain baru ke trusted_domains
echo "🔧 Menambahkan domain baru ke trusted_domains..."
sudo php -r "
\$config_file = '/var/www/owncloud/config/config.php';
\$config = include \$config_file;
if (!in_array('$custom_url', \$config['trusted_domains'])) {
    \$config['trusted_domains'][] = '$custom_url';
    file_put_contents(\$config_file, '<?php return ' . var_export(\$config, true) . ';');
    echo '✅ Trusted domain berhasil ditambahkan: $custom_url\n';
} else {
    echo '⚠️ Domain sudah ada di trusted_domains.\n';
}
"

# Membuat konfigurasi Apache dengan URL kustom
echo "🔧 Mengatur konfigurasi Apache untuk $custom_url..."
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

# Mengaktifkan konfigurasi Apache dan module rewrite
echo "🔄 Mengaktifkan konfigurasi Apache..."
sudo a2dissite 000-default.conf
sudo a2ensite owncloud.conf
sudo a2enmod rewrite

# Restart Apache
echo "🔄 Merestart Apache..."
sudo systemctl restart apache2

# Pesan akhir
echo "✅ Instalasi OwnCloud selesai!"
echo "🔗 Akses OwnCloud melalui: http://$custom_url"
