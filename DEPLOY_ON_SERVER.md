# 🚀 Projekt auf Server übertragen und deployen

## Schritt 1: Projekt auf Server übertragen

Du hast mehrere Optionen:

### Option A: Via Git (Empfohlen - wenn Code in Git-Repo)

```bash
# Auf dem Server:
cd ~
git clone <dein-git-repo-url> xcoin-website
# oder falls du GitHub/GitLab verwendest:
# git clone https://github.com/dein-username/xcoin-website.git xcoin-website
cd xcoin-website
```

### Option B: Via SCP (vom lokalen Rechner)

**Auf deinem lokalen Rechner (Mac/Terminal):**

```bash
cd /Users/fabianschuck/Desktop/Xcoin_WebsiteGit
scp -r ./* Xcoin@82.221.100.116:~/xcoin-website/
```

### Option C: Via rsync (empfohlen - effizienter)

**Auf deinem lokalen Rechner:**

```bash
cd /Users/fabianschuck/Desktop/Xcoin_WebsiteGit
rsync -avz --exclude 'node_modules' --exclude '.next' --exclude '.git' ./ Xcoin@82.221.100.116:~/xcoin-website/
```

---

## Schritt 2: Server vorbereiten

**Auf dem Server:**

```bash
# Zum Projekt-Verzeichnis
cd ~/xcoin-website

# Deployment-Script ausführen (oder manuell)
chmod +x scripts/deploy-on-server.sh
./scripts/deploy-on-server.sh
```

**Oder manuell:**

```bash
# 1. Node.js installieren (falls nicht vorhanden)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. PM2 installieren
sudo npm install -g pm2

# 3. PostgreSQL installieren
sudo apt-get install -y postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 4. Nginx installieren
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# 5. Build-Tools
sudo apt-get install -y build-essential python3
```

---

## Schritt 3: Dependencies installieren

**Auf dem Server:**

```bash
cd ~/xcoin-website
npm install --legacy-peer-deps
```

---

## Schritt 4: Datenbank einrichten

**Auf dem Server:**

```bash
# PostgreSQL User und Database erstellen
sudo -u postgres psql
```

**In PostgreSQL Shell:**

```sql
CREATE USER xcoin_user WITH PASSWORD 'DEIN_SICHERES_PASSWORT_HIER';
CREATE DATABASE xcoin_db OWNER xcoin_user;
GRANT ALL PRIVILEGES ON DATABASE xcoin_db TO xcoin_user;
\q
```

**Dann Prisma Setup:**

```bash
cd ~/xcoin-website
npm run db:generate
npm run db:push
```

---

## Schritt 5: Environment-Variablen konfigurieren

**Auf dem Server:**

```bash
cd ~/xcoin-website
nano .env.local
```

**Inhalt von `.env.local`:**

```env
# Database Configuration
DATABASE_URL="postgresql://xcoin_user:DEIN_PASSWORT@localhost:5432/xcoin_db?schema=public"

# Next.js Configuration
NODE_ENV=production
NEXT_PUBLIC_SITE_URL=https://deine-domain.com

# Email Configuration (optional - später)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=your-email@example.com
SMTP_PASSWORD=your-password
SMTP_FROM=noreply@xcoin.ws
SMTP_TO=info@xcoin.ws

# Security (generiere mit: openssl rand -base64 32)
NEXTAUTH_SECRET=$(openssl rand -base64 32)
NEXTAUTH_URL=https://deine-domain.com
```

**Speichern:** `Ctrl+O`, `Enter`, `Ctrl+X`

---

## Schritt 6: Production Build erstellen

**Auf dem Server:**

```bash
cd ~/xcoin-website
npm run build
```

**Warte bis Build fertig ist** (kann ein paar Minuten dauern)

---

## Schritt 7: PM2 starten

**Auf dem Server:**

```bash
cd ~/xcoin-website

# App starten
pm2 start npm --name "xcoin-website" -- start

# PM2 beim System-Start aktivieren
pm2 save
pm2 startup

# Status prüfen
pm2 status
pm2 logs xcoin-website
```

**App sollte jetzt auf `http://localhost:3000` laufen**

---

## Schritt 8: Nginx konfigurieren

**Auf dem Server:**

```bash
cd ~/xcoin-website

# Nginx Config Script ausführen
chmod +x scripts/nginx-config.sh
./scripts/nginx-config.sh deine-domain.com
```

**Oder manuell:**

```bash
# Nginx Config erstellen
sudo nano /etc/nginx/sites-available/xcoin-website
```

**Inhalt:**

```nginx
server {
    listen 80;
    server_name deine-domain.com www.deine-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

**Dann:**

```bash
# Config aktivieren
sudo ln -s /etc/nginx/sites-available/xcoin-website /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default  # Entferne default

# Config testen
sudo nginx -t

# Nginx neu starten
sudo systemctl restart nginx
```

---

## Schritt 9: Domain DNS konfigurieren

**In deinem Domain-Provider (z.B. Namecheap, GoDaddy, etc.):**

1. Gehe zu DNS-Einstellungen
2. Füge A-Record hinzu:
   - **Name:** `@` (oder leere Feld)
   - **Value:** `82.221.100.116` (Server IP)
   - **TTL:** 3600

3. Optional: CNAME für www:
   - **Name:** `www`
   - **Value:** `deine-domain.com`
   - **TTL:** 3600

**Warte 5-30 Minuten** bis DNS propagiert ist (teste mit: `ping deine-domain.com`)

---

## Schritt 10: SSL/HTTPS einrichten (Certbot)

**Auf dem Server:**

```bash
# Certbot installieren
sudo apt-get install -y certbot python3-certbot-nginx

# SSL-Zertifikat erstellen
sudo certbot --nginx -d deine-domain.com -d www.deine-domain.com

# Auto-Renewal testen
sudo certbot renew --dry-run
```

**Certbot konfiguriert automatisch Nginx für HTTPS!**

---

## Schritt 11: Firewall konfigurieren

**Auf dem Server:**

```bash
# Firewall aktivieren (falls nicht schon aktiv)
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable

# Status prüfen
sudo ufw status
```

---

## Schritt 12: Testen

**1. Lokal auf Server testen:**
```bash
curl http://localhost:3000
```

**2. Über Domain testen (nach DNS-Propagation):**
```bash
curl http://deine-domain.com
```

**3. Im Browser öffnen:**
- `http://deine-domain.com` (HTTP)
- `https://deine-domain.com` (HTTPS - nach Certbot)

---

## Troubleshooting

### PM2 läuft nicht

```bash
pm2 status
pm2 logs xcoin-website
pm2 restart xcoin-website
```

### Nginx Fehler

```bash
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
sudo systemctl status nginx
```

### Build Fehler

```bash
cd ~/xcoin-website
npm run build
# Prüfe Fehler-Meldungen
```

### Port bereits belegt

```bash
sudo lsof -i :3000
sudo netstat -tulpn | grep :3000
```

### DNS nicht propagiert

```bash
nslookup deine-domain.com
dig deine-domain.com
# Warte 5-30 Minuten
```

---

## Nächste Schritte

- ✅ Monitoring einrichten
- ✅ Automatische Backups konfigurieren
- ✅ Logs-Rotation einrichten
- ✅ Security-Hardening (Fail2ban, etc.)

---

## Updates deployen

```bash
cd ~/xcoin-website
git pull  # Falls Git verwendet wird
npm install --legacy-peer-deps
npm run build
pm2 restart xcoin-website
```
