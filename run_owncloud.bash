#!/bin/bash

# Meminta input URL baru dari pengguna
read -p "Masukkan URL baru untuk OwnCloud (misalnya: putraganteng.com): " new_url

# Buka file konfigurasi dan tambahkan trusted_domains secara manual
sudo nano /var/www/owncloud/config/config.php

echo "
# Langkah 1: Tambahkan trusted domain di dalam bagian ini:
'trusted_domains' =>
array (
    0 => 'localhost',
    1 => '$new_url',
),
"

echo "Tekan 'CTRL + O' untuk menyimpan, dan 'CTRL + X' untuk keluar."

# Memastikan konfigurasi Apache sudah benar dengan URL baru
sudo tee /etc/apache2/sites-available/owncloud.conf > /dev/null << EOL
<VirtualHost *:80>
  ServerName $new_url
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

# Menonaktifkan konfigurasi default Apache dan mengaktifkan konfigurasi OwnCloud baru
sudo a2dissite 000-default.conf
sudo a2ensite owncloud.conf
sudo a2enmod rewrite

# Restart Apache untuk menerapkan perubahan
sudo systemctl restart apache2

# Pesan akhir
echo "OwnCloud sekarang berjalan di URL: http://$new_url"
