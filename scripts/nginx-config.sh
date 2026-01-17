#!/bin/bash

# Nginx Konfiguration für Xcoin Website
# Führe dieses Script auf dem Server aus

set -e

DOMAIN="${1:-your-domain.com}"
NGINX_CONFIG="/etc/nginx/sites-available/xcoin-website"

echo "🌐 Nginx Konfiguration für Domain: $DOMAIN"
echo "==========================================="
echo ""

# Prüfe ob Domain angegeben wurde
if [ "$DOMAIN" = "your-domain.com" ]; then
    echo "⚠️  Warnung: Bitte Domain als Parameter angeben!"
    echo "Usage: ./nginx-config.sh your-domain.com"
    echo ""
    read -p "Domain eingeben (oder Enter für manuelle Konfiguration): " DOMAIN_INPUT
    if [ -n "$DOMAIN_INPUT" ]; then
        DOMAIN="$DOMAIN_INPUT"
    else
        echo "❌ Keine Domain angegeben. Bitte manuell konfigurieren."
        exit 1
    fi
fi

echo "📝 Erstelle Nginx Config für: $DOMAIN"

# Backup existierende Config (falls vorhanden)
if [ -f "$NGINX_CONFIG" ]; then
    echo "📦 Backup erstellen..."
    sudo cp "$NGINX_CONFIG" "${NGINX_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Nginx Config erstellen
sudo tee "$NGINX_CONFIG" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # Redirect www to non-www (optional - entferne wenn beide erlaubt sein sollen)
    # if (\$host = www.$DOMAIN) {
    #     return 301 http://$DOMAIN\$request_uri;
    # }

    # Logging
    access_log /var/log/nginx/xcoin-access.log;
    error_log /var/log/nginx/xcoin-error.log;

    # Max body size (für File-Uploads)
    client_max_body_size 10M;

    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Next.js App (PM2 läuft auf Port 3000)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Static files caching (optional)
    location /_next/static {
        proxy_pass http://localhost:3000;
        proxy_cache_valid 200 365d;
        add_header Cache-Control "public, immutable";
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

echo "✅ Nginx Config erstellt: $NGINX_CONFIG"

# Config testen
echo "🔍 Nginx Config testen..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx Config ist gültig!"
    
    # Config aktivieren
    echo "🔗 Config aktivieren..."
    sudo ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/
    
    # Entferne default config (optional)
    if [ -f "/etc/nginx/sites-enabled/default" ]; then
        echo "🗑️  Entferne default Nginx config..."
        sudo rm /etc/nginx/sites-enabled/default
    fi
    
    # Nginx neu starten
    echo "🔄 Nginx neu starten..."
    sudo systemctl restart nginx
    
    echo ""
    echo "✅ Nginx erfolgreich konfiguriert!"
    echo ""
    echo "📋 Nächste Schritte:"
    echo "1. Stelle sicher, dass PM2 läuft: pm2 status"
    echo "2. Stelle sicher, dass die App auf Port 3000 läuft: curl http://localhost:3000"
    echo "3. Teste die Domain: curl http://$DOMAIN"
    echo "4. SSL/HTTPS einrichten: sudo certbot --nginx -d $DOMAIN"
    echo ""
else
    echo "❌ Nginx Config hat Fehler! Bitte manuell prüfen."
    exit 1
fi
