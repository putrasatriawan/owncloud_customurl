tutorial !



This guide will walk you through the steps to install OwnCloud with a custom URL using a Bash script. Follow the instructions below to set up OwnCloud on your server.

## Prerequisites

- A server running Ubuntu 20.04 or later.
- Root or sudo access to the server.
- A domain name that you want to use as a custom URL.

## Installation Steps

1. **Update the package repository:**
   Make sure your system packages are up-to-date before starting the installation.
   ```bash
sudo apt install curl
wget  https://raw.githubusercontent.com/putrasatriawan/owncloud_customurl/refs/heads/main/install_owncloud.bash
chmod +x install_owncloud.bash
chown -R www-data:www-data /var/www/owncloud
chmod -R 755 /var/www/owncloud# OwnCloud Custom URL Installation Guide

sudo bash ./install_owncloud.bash
