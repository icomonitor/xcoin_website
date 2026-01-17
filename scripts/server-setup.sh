#!/bin/bash

# Xcoin Website - Server Setup Script
# Führe dieses Script auf dem Server nach der SSH-Verbindung aus

set -e

echo "🚀 Xcoin Website - Server Setup"
echo "================================"
echo ""

# 1. System Update
echo "📦 System aktualisieren..."
sudo apt-get update -y
sudo apt-get upgrade -y

# 2. Node.js und npm installieren (falls nicht vorhanden)
if ! command -v node &> /dev/null; then
    echo "📦 Node.js installieren..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "✓ Node.js bereits installiert: $(node --version)"
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm fehlt! Bitte manuell installieren."
    exit 1
else
    echo "✓ npm bereits installiert: $(npm --version)"
fi

# 3. PM2 installieren (Process Manager)
if ! command -v pm2 &> /dev/null; then
    echo "📦 PM2 installieren..."
    sudo npm install -g pm2
else
    echo "✓ PM2 bereits installiert: $(pm2 --version)"
fi

# 4. Nginx installieren (falls nicht vorhanden)
if ! command -v nginx &> /dev/null; then
    echo "📦 Nginx installieren..."
    sudo apt-get install -y nginx
else
    echo "✓ Nginx bereits installiert: $(nginx -v 2>&1)"
fi

# 5. Git installieren (falls nicht vorhanden)
if ! command -v git &> /dev/null; then
    echo "📦 Git installieren..."
    sudo apt-get install -y git
else
    echo "✓ Git bereits installiert: $(git --version)"
fi

# 6. PostgreSQL installieren (für Datenbank)
if ! command -v psql &> /dev/null; then
    echo "📦 PostgreSQL installieren..."
    sudo apt-get install -y postgresql postgresql-contrib
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
else
    echo "✓ PostgreSQL bereits installiert"
fi

# 7. Build-Tools installieren (für Native Dependencies)
echo "📦 Build-Tools installieren..."
sudo apt-get install -y build-essential python3

# 8. Firewall konfigurieren (UFW)
if command -v ufw &> /dev/null; then
    echo "🔥 Firewall konfigurieren..."
    sudo ufw allow 22/tcp   # SSH
    sudo ufw allow 80/tcp   # HTTP
    sudo ufw allow 443/tcp  # HTTPS
    sudo ufw --force enable || true
fi

# 9. Verzeichnisse erstellen
echo "📁 Verzeichnisse erstellen..."
mkdir -p ~/xcoin-website
mkdir -p ~/xcoin-website/logs

echo ""
echo "✅ Server-Setup abgeschlossen!"
echo ""
echo "📋 Nächste Schritte:"
echo "1. Projekt auf Server übertragen (Git clone oder SCP)"
echo "2. .env Datei mit Datenbank-Credentials erstellen"
echo "3. npm install ausführen"
echo "4. npm run build ausführen"
echo "5. PM2 starten: pm2 start npm --name 'xcoin-website' -- start"
echo "6. Nginx konfigurieren für Reverse Proxy"
echo ""
