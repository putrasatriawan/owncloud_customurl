#!/bin/bash

# Meminta URL baru dari pengguna
read -p "Masukkan URL baru untuk OwnCloud (misalnya: cloud.example.com): " custom_url

# Membuat ulang konfigurasi Apache dengan URL baru
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

# Mengaktifkan konfigurasi baru dan restart Apache
a2ensite owncloud.conf
a2enmod rewrite
systemctl restart apache2

echo "OwnCloud sekarang berjalan di URL: $custom_url"