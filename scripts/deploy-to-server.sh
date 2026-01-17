#!/bin/bash

# Xcoin Website - Deploy to Server Script
# Führe dieses Script lokal aus, um das Projekt auf den Server zu übertragen

set -e

SERVER_IP="82.221.100.116"
SERVER_USER="Xcoin"
SERVER_DIR="~/xcoin-website"
LOCAL_DIR="$(pwd)"

echo "🚀 Xcoin Website - Deployment zu Server"
echo "========================================"
echo ""
echo "Server: ${SERVER_USER}@${SERVER_IP}"
echo "Zielverzeichnis: ${SERVER_DIR}"
echo ""

# Prüfe ob .env.local existiert
if [ ! -f .env.local ]; then
    echo "⚠️  Warnung: .env.local nicht gefunden!"
    echo "Erstelle .env.local Template..."
    cat > .env.local << EOF
# Database Configuration
DATABASE_URL="postgresql://user:password@localhost:5432/xcoin_db?schema=public"

# Next.js Configuration
NODE_ENV=production
NEXT_PUBLIC_SITE_URL=https://your-domain.com

# Email Configuration (optional - später für Contact Form)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=your-email@example.com
SMTP_PASSWORD=your-password

# Security (generiere mit: openssl rand -base64 32)
NEXTAUTH_SECRET=your-secret-key-here
NEXTAUTH_URL=https://your-domain.com
EOF
    echo "✓ .env.local Template erstellt"
    echo "⚠️  Bitte bearbeite .env.local mit deinen echten Credentials!"
    read -p "Press Enter to continue..."
fi

# Erstelle .gitignore für .env.local falls nicht vorhanden
if ! grep -q ".env.local" .gitignore 2>/dev/null; then
    echo ".env.local" >> .gitignore
fi

# Erstelle Production Build lokal (Test)
echo "📦 Production Build erstellen..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Build fehlgeschlagen! Bitte Fehler beheben."
    exit 1
fi

echo "✅ Build erfolgreich!"
echo ""
echo "📋 Nächste Schritte:"
echo ""
echo "1. SSH zum Server verbinden:"
echo "   ssh ${SERVER_USER}@${SERVER_IP}"
echo ""
echo "2. Auf dem Server ausführen:"
echo "   cd ~ && wget -O server-setup.sh https://raw.githubusercontent.com/your-repo/xcoin-website/main/scripts/server-setup.sh"
echo "   chmod +x server-setup.sh"
echo "   ./server-setup.sh"
echo ""
echo "3. Projekt auf Server übertragen (Option A - Git):"
echo "   cd ~/xcoin-website"
echo "   git clone <your-repo-url> ."
echo "   npm install"
echo ""
echo "4. Oder Option B - SCP (manuell):"
echo "   scp -r ${LOCAL_DIR}/* ${SERVER_USER}@${SERVER_IP}:${SERVER_DIR}/"
echo ""
echo "5. .env.local auf Server übertragen:"
echo "   scp .env.local ${SERVER_USER}@${SERVER_IP}:${SERVER_DIR}/.env.local"
echo ""
echo "6. Auf Server: Build und Start:"
echo "   cd ~/xcoin-website"
echo "   npm run build"
echo "   pm2 start npm --name 'xcoin-website' -- start"
echo "   pm2 save"
echo "   pm2 startup"
echo ""
