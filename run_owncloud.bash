#!/bin/bash

# Meminta input URL baru dari pengguna
read -p "Masukkan URL baru untuk OwnCloud (misalnya: putraganteng.com): " new_url

# Menambahkan URL baru ke trusted_domains
sudo sed -i "/'trusted_domains' =>/a\ \ \ \ 2 => '$new_url'," /var/www/owncloud/config/config.php

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

# Restart Apache untuk menerapkan perubahan
sudo systemctl restart apache2

# Pesan akhir
echo "OwnCloud sekarang berjalan di URL: http://$new_url"
