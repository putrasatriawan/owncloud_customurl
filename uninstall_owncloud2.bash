#!/bin/bash

# Banner untuk konfirmasi
echo "============================================="
echo "        🚀 Uninstall OwnCloud Dimulai 🚀"
echo "             By Putra - Cloud Enthusiast"
echo "============================================="
echo "⚠️  Peringatan: Script ini akan menghapus semua file dan konfigurasi terkait OwnCloud."
read -p "Apakah Anda yakin ingin melanjutkan? (y/n): " confirm

# Batalkan jika pengguna tidak setuju
if [[ $confirm != "y" ]]; then
    echo "❌ Proses dibatalkan."
    exit 0
fi

# Hentikan layanan Apache dan MariaDB
echo "🔄 Menghentikan layanan Apache dan MariaDB..."
sudo systemctl stop apache2
sudo systemctl stop mariadb

# Hapus paket terkait
echo "🗑️ Menghapus paket OwnCloud, Apache, PHP, dan MariaDB..."
sudo apt remove --purge -y apache2 mariadb-server php7.4 \
php7.4-{mysql,intl,curl,json,gd,xml,mbstring,zip} owncloud-complete-files
sudo apt autoremove -y
sudo apt clean

# Hapus direktori dan konfigurasi OwnCloud
echo "🗑️ Menghapus direktori dan konfigurasi OwnCloud..."
sudo rm -rf /var/www/owncloud
sudo rm -rf /etc/apache2/sites-available/owncloud.conf
sudo rm -rf /etc/apache2/sites-enabled/owncloud.conf

# Hapus database dan pengguna terkait di MariaDB
echo "🗑️ Menghapus database dan pengguna OwnCloud di MariaDB..."
sudo mysql --user=root <<EOF
DROP DATABASE IF EXISTS ownclouddb;
DROP USER IF EXISTS 'ownclouduser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Hapus konfigurasi default Apache
echo "🔄 Menghapus konfigurasi default Apache..."
sudo rm -rf /etc/apache2/sites-available/000-default.conf
sudo systemctl restart apache2

# Hapus repository OwnCloud
echo "🗑️ Menghapus repository OwnCloud..."
sudo rm -rf /etc/apt/sources.list.d/owncloud.list
sudo rm -rf /etc/apt/trusted.gpg.d/owncloud.gpg

# Hapus log dan sisa konfigurasi
echo "🗑️ Menghapus log dan sisa konfigurasi..."
sudo rm -rf /var/log/apache2/owncloud_*.log
sudo rm -rf /var/www/owncloud/data/owncloud.log

# Hapus script instalasi jika ditemukan
echo "🗑️ Menghapus script instalasi dan file wget jika ada..."
SCRIPT_DIR=$(dirname "$0")
sudo rm -f "$SCRIPT_DIR/install_owncloud.sh"
sudo rm -f "$SCRIPT_DIR/uninstall_owncloud.sh"

# Berikan pesan akhir
echo "✅ Uninstall OwnCloud selesai! Semua file dan konfigurasi telah dihapus."
echo "============================================="
echo "         By Putra - Cloud Enthusiast"
echo "============================================="
