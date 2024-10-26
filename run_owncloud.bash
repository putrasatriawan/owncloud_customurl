#!/bin/bash

# Meminta input URL baru dari pengguna
read -p "Masukkan URL baru untuk OwnCloud (misalnya: putraganteng.com): " new_url

# Backup konfigurasi sebelum perubahan
echo "📋 Membackup file konfigurasi..."
sudo cp /var/www/owncloud/config/config.php /var/www/owncloud/config/config.php.bak

# Menambahkan domain baru ke trusted_domains dengan aman menggunakan PHP
echo "🔧 Menambahkan domain baru ke trusted_domains..."
sudo php -r "
\$config_file = '/var/www/owncloud/config/config.php';
\$config = include \$config_file;
if (!in_array('$new_url', \$config['trusted_domains'])) {
    \$config['trusted_domains'][] = '$new_url';
    file_put_contents(\$config_file, '<?php return ' . var_export(\$config, true) . ';');
    echo '✅ Trusted domain berhasil ditambahkan: $new_url\n';
} else {
    echo '⚠️ Domain sudah ada di trusted_domains.\n';
}
"

# Membuat konfigurasi Apache dengan URL baru
echo "🔧 Mengatur konfigurasi Apache untuk $new_url..."
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

# Menonaktifkan konfigurasi default Apache dan mengaktifkan OwnCloud
echo "🔄 Mengaktifkan konfigurasi Apache..."
sudo a2dissite 000-default.conf
sudo a2ensite owncloud.conf
sudo a2enmod rewrite

# Restart Apache untuk menerapkan perubahan
echo "🔄 Merestart Apache..."
sudo systemctl restart apache2

# Pesan akhir
echo "✅ Run ulang OwnCloud selesai!"
echo "🔗 OwnCloud sekarang dapat diakses melalui: http://$new_url"
