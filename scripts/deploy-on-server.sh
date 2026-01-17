#!/bin/bash

# Xcoin Website - Deployment Script für Server
# Führe dieses Script auf dem Server aus (nach Projekt-Transfer)

set -e

echo "🚀 Xcoin Website - Server Deployment"
echo "====================================="
echo ""

# 1. System Update (falls noch nicht gemacht)
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

# 3. PM2 installieren (falls nicht vorhanden)
if ! command -v pm2 &> /dev/null; then
    echo "📦 PM2 installieren..."
    sudo npm install -g pm2
else
    echo "✓ PM2 bereits installiert: $(pm2 --version)"
fi

# 4. PostgreSQL installieren (falls nicht vorhanden)
if ! command -v psql &> /dev/null; then
    echo "📦 PostgreSQL installieren..."
    sudo apt-get install -y postgresql postgresql-contrib
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
else
    echo "✓ PostgreSQL bereits installiert"
fi

# 5. Nginx installieren (falls nicht vorhanden)
if ! command -v nginx &> /dev/null; then
    echo "📦 Nginx installieren..."
    sudo apt-get install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
else
    echo "✓ Nginx bereits installiert: $(nginx -v 2>&1)"
fi

# 6. Build-Tools installieren
echo "📦 Build-Tools installieren..."
sudo apt-get install -y build-essential python3

# 7. Prüfe ob Projekt-Verzeichnis existiert
if [ ! -d "~/xcoin-website" ]; then
    echo "❌ Projekt-Verzeichnis nicht gefunden!"
    echo "Bitte erst: git clone <repo-url> ~/xcoin-website"
    exit 1
fi

cd ~/xcoin-website

# 8. Dependencies installieren
echo "📦 Dependencies installieren..."
npm install --legacy-peer-deps

# 9. Prisma Client generieren
if [ -f "prisma/schema.prisma" ]; then
    echo "📦 Prisma Client generieren..."
    npm run db:generate || npx prisma generate
fi

echo ""
echo "✅ Grund-Setup abgeschlossen!"
echo ""
echo "📋 Nächste Schritte:"
echo "1. .env.local erstellen und konfigurieren"
echo "2. Datenbank einrichten (siehe DATABASE_SETUP.md)"
echo "3. npm run build ausführen"
echo "4. PM2 starten: pm2 start npm --name 'xcoin-website' -- start"
echo "5. Nginx konfigurieren (siehe scripts/nginx-config.sh)"
echo ""
