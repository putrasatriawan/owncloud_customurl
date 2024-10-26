#!/bin/bash

# Fungsi untuk menampilkan banner dan pesan
showBanner() {
  echo "============================================="
  echo "        🚀 Jalankan Ulang OwnCloud! 🚀"
  echo "             By Putra - Cloud Enthusiast"
  echo "============================================="
  echo ""
}

# Tampilkan banner
showBanner

# Meminta input URL baru dari pengguna
read -p "🌐 Masukkan URL baru untuk OwnCloud (misalnya: cloud.example.com): " custom_url

# Membuka file konfigurasi untuk menambahkan trusted domain secara manual
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

# Memperbarui konfigurasi Apache dengan URL baru
echo "🔧 Memperbarui konfigurasi Apache dengan URL: $custom_url..."
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

# Mengaktifkan konfigurasi Apache dan merestart layanan
echo "🔄 Mengaktifkan konfigurasi dan merestart Apache..."
sudo a2ensite owncloud.conf
sudo systemctl restart apache2

# Pesan akhir
echo "🎉 OwnCloud sekarang berjalan di URL: http://$custom_url"
echo "============================================="
echo "         By Putra - Cloud Enthusiast"
echo "============================================="
