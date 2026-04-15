#!/bin/bash

clear
echo "======================================"
echo "🚀 Wings Full Auto Installer"
echo "👨‍💻 Made by Sumit"
echo "======================================"
echo ""
echo "Select OS:"
echo "1) Ubuntu Wings Setup"
echo "2) Debian Wings Setup"
echo "3) Exit"
echo ""

read -p "Enter choice [1-3]: " choice

install_wings() {

echo "⚙️ Updating system..."
apt update -y && apt upgrade -y

echo "📦 Installing dependencies..."
apt install curl tar unzip certbot -y

echo "🐳 Installing Docker..."
curl -sSL https://get.docker.com/ | bash
systemctl enable --now docker

echo "📁 Creating directories..."
mkdir -p /etc/pterodactyl
cd /etc/pterodactyl

echo "📦 Downloading Wings..."
curl -L -o wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64

chmod +x wings
mv wings /usr/local/bin/

echo "⚙️ Creating Wings service..."
cat <<EOL > /etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
ExecStart=/usr/local/bin/wings
Restart=always

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable wings

echo ""
echo "======================================"
echo "📌 Paste Node Config (from panel)"
echo "👉 Then press CTRL+D"
echo "======================================"

CONFIG=$(cat)

echo "$CONFIG" > /etc/pterodactyl/config.yml

echo "🚀 Starting Wings..."
systemctl start wings

echo ""
echo "✅ DONE! Node should be ONLINE 🟢"
}

case $choice in
1)
echo "🐧 Ubuntu Selected"
install_wings
;;

2)
echo "🐧 Debian Selected"
install_wings
;;

3)
echo "Exit..."
exit
;;

*)
echo "❌ Invalid option"
;;

esac
