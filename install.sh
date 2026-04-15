#!/bin/bash

clear
echo "======================================"
echo "🚀 Pterodactyl Auto Wings Installer"
echo "👨‍💻 Made by Sumit"
echo "======================================"

echo ""
echo "📌 Paste Node Config Below"
echo "👉 Then press CTRL+D"
echo ""

CONFIG=$(cat)

apt update -y && apt upgrade -y
apt install curl tar unzip -y

echo "🐳 Installing Docker..."
curl -sSL https://get.docker.com/ | bash
systemctl enable --now docker

mkdir -p /etc/pterodactyl
cd /etc/pterodactyl

echo "📦 Downloading Wings..."
curl -L -o wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64

chmod +x wings
mv wings /usr/local/bin/

echo "$CONFIG" > /etc/pterodactyl/config.yml

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
systemctl start wings

echo ""
echo "✅ DONE! Node should be ONLINE"
