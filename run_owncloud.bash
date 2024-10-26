#!/bin/bash

# Meminta input URL baru dari pengguna
read -p "Masukkan URL baru untuk OwnCloud (misalnya: cloud.example.com): " new_url

# Menghapus semua entri trusted_domains dari config.php
sudo sed -i "/'trusted_domains' =>/,/),/d" /var/www/owncloud/config/config.php

# Menambahkan entri baru ke trusted_domains
sudo sed -i "/);/i\  'trusted_domains' => array (\n    0 => 'localhost',\n    1 => '$new_url',\n  )," /var/www/owncloud/config/config.php

# Memperbarui konfigurasi Apache dengan URL baru
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
