sudo apt install curl
wget  https://raw.githubusercontent.com/putrasatriawan/owncloud_customurl/refs/heads/main/install_owncloud.bash
chmod +x install_owncloud.bash
chown -R www-data:www-data /var/www/owncloud
chmod -R 755 /var/www/owncloud
sudo bash ./install_owncloud.bash
