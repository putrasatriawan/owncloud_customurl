#!/bin/bash

# Menampilkan pesan selamat datang dan meminta input URL kustom
echo "Selamat datang di Instalasi OwnCloud! By PUTRA"
read -p "Masukkan URL kustom untuk konfigurasi (misalnya: putragenteng.com): " custom_url

# Memastikan semua dependensi terinstal
echo "Memeriksa dan menginstal dependensi yang diperlukan..."

# Fungsi untuk menginstal paket jika belum ada
function install_if_not_installed {
  if ! dpkg -l | grep -qw $1; then
    echo "Menginstal $1..."
    apt-get install -y $1
  else
    echo "$1 sudah terinstal."
  fi
}

# Periksa dan instal paket yang diperlukan
apt-get update

install_if_not_installed curl
install_if_not_installed wget
install_if_not_installed gnupg2
install_if_not_installed software-properties-common
install_if_not_installed apache2
install_if_not_installed mariadb-server

# Menambahkan repository PHP 7.4
add-apt-repository ppa:ondrej/php --yes &> /dev/null
apt-get update

# Instal PHP dan modul yang diperlukan
install_if_not_installed php7.4
install_if_not_installed libapache2-mod-php7.4
install_if_not_installed php7.4-mysql
install_if_not_installed php7.4-intl
install_if_not_installed php7.4-curl
install_if_not_installed php7.4-json
install_if_not_installed php7.4-gd
install_if_not_installed php7.4-xml
install_if_not_installed php7.4-mbstring
install_if_not_installed php7.4-zip
install_if_not_installed php-pear

# Menambahkan repository OwnCloud
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10.9.1/Ubuntu_22.04/ /' > /etc/apt/sources.list.d/owncloud.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:/10/Ubuntu_20.04/Release.key | gpg --dearmor -o /usr/share/keyrings/owncloud.key
apt-get update

# Instal OwnCloud
install_if_not_installed owncloud-complete-files

# Membuat direktori OwnCloud jika belum ada
if [ ! -d "/var/www/owncloud" ]; then
  mkdir -p /var/www/owncloud
fi

# Setel kepemilikan dan izin untuk direktori OwnCloud
chown -R www-data:www-data /var/www/owncloud
chmod -R 755 /var/www/owncloud

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
EOL

# Mengaktifkan konfigurasi Apache dan restart service
a2ensite owncloud.conf
a2enmod rewrite
systemctl restart apache2

# Mengatur ulang izin dan kepemilikan setelah konfigurasi Apache
chown -R www-data:www-data /var/www/owncloud
chmod -R 755 /var/www/owncloud

# Konfigurasi database MySQL untuk OwnCloud
echo "Mengkonfigurasi database MySQL untuk OwnCloud..."
mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ownclouddb;
GRANT ALL PRIVILEGES ON ownclouddb.* TO 'ownclouduser'@'localhost' IDENTIFIED BY 'owncloudpass';
FLUSH PRIVILEGES;
EOF

# Menjalankan instalasi OwnCloud
echo "Menjalankan instalasi OwnCloud..."
sudo -u www-data php /var/www/owncloud/occ maintenance:install \
   --database "mysql" \
   --database-name "ownclouddb" \
   --database-user "ownclouduser" \
   --database-pass "owncloudpass" \
   --admin-user "admin" \
   --admin-pass "adminpassword"

# Mengatur ulang izin dan kepemilikan setelah instalasi
chown -R www-data:www-data /var/www/owncloud
chmod -R 755 /var/www/owncloud

echo "Instalasi OwnCloud selesai! Anda dapat mengaksesnya di http://$custom_url"
