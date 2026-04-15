#!/bin/bash

clear
echo "======================================"
echo "🚀 Pterodactyl Wings Professional Installer"
echo "👨‍💻 Made by Sumit"
echo "======================================"

# Root check
if [ "$EUID" -ne 0 ]; then
  echo "❌ Run as root"
  exit
fi

# OS detect
if [ -f /etc/debian_version ]; then
  OS="Debian/Ubuntu"
else
  echo "❌ Unsupported OS"
  exit
fi

echo "✅ OS Detected: $OS"

# Update system
echo "⚙️ Updating system..."
apt update -y && apt upgrade -y

# Install dependencies
echo "📦 Installing dependencies..."
apt install -y curl tar unzip ufw certbot

# Firewall setup
echo "🔥 Configuring firewall..."
ufw allow 22
ufw allow 8080
ufw allow 2022
ufw --force enable

# Install Docker
echo "🐳 Installing Docker..."
curl -sSL https://get.docker.com/ | bash
systemctl enable --now docker

# Install Wings
echo "📦 Installing Wings..."
mkdir -p /etc/pterodactyl
cd /etc/pterodactyl

curl -L -o wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x wings
mv wings /usr/local/bin/

# Create service
echo "⚙️ Creating service..."
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
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable wings

# SSL option
echo ""
read -p "🌐 Do you want to setup SSL? (y/n): " sslchoice

if [[ "$sslchoice" == "y" ]]; then
  read -p "Enter domain: " domain
  echo "🔐 Installing SSL..."
  certbot certonly --standalone -d $domain --non-interactive --agree-tos -m admin@$domain
fi

# Config
echo ""
echo "======================================"
echo "📌 Paste Node Config (FULL)"
echo "👉 Then press CTRL+D"
echo "======================================"

CONFIG=$(cat)

echo "$CONFIG" > /etc/pterodactyl/config.yml

# Start Wings
echo "🚀 Starting Wings..."
systemctl start wings

# Final status
echo ""
systemctl status wings --no-pager

echo ""
echo "======================================"
echo "✅ INSTALL COMPLETE"
echo "🟢 Check panel → Node ONLINE"
echo "======================================"
