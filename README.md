Tentu, saya akan bantu gabungkan semua informasi yang telah kita diskusikan menjadi satu skrip README.md yang komprehensif dan siap digunakan di GitHub.

README.md

Markdown
## Instalasi dan Konfigurasi OwnCloud dengan Domain Kustom

### Pendahuluan
Skrip ini akan memandu Anda secara lengkap dalam menginstal dan mengkonfigurasi OwnCloud pada sistem berbasis Debian (seperti Ubuntu, Raspbian, dll.) dengan domain kustom. Dengan skrip ini, Anda akan memiliki cloud storage pribadi yang aman dan dapat diakses dari mana saja.

### Prasyarat
* **Sistem Operasi:** Sistem berbasis Debian (misalnya, Ubuntu, Debian, Raspbian)
* **Akses:** Akses root atau sudo ke server
* **Domain:** Domain yang sudah terpoin ke server Anda

### Langkah-langkah Instalasi

1. **Update Paket:**
   ```bash
   sudo apt install curl
   wget  https://raw.githubusercontent.com/putrasatriawan/owncloud_customurl/refs/heads/main/install_first_owncloud.bash
   chmod +x install_first_owncloud.bash
   sudo bash ./install_first_owncloud.bash

   wget https://raw.githubusercontent.com/putrasatriawan/owncloud_customurl/refs/heads/main/install_owncloud.bash
   chmod +x install_owncloud.bash
   sudo bash ./install_owncloud.bash



   
