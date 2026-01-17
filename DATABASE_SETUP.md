# 🗄️ Datenbank-Setup für Xcoin Website

## Schritt 1: Prisma installieren

```bash
npm install
# oder
pnpm install
```

## Schritt 2: Datenbank erstellen

### PostgreSQL (empfohlen)

```bash
# Auf dem Server:
sudo -u postgres psql

# In PostgreSQL Shell:
CREATE USER xcoin_user WITH PASSWORD 'your-secure-password';
CREATE DATABASE xcoin_db OWNER xcoin_user;
GRANT ALL PRIVILEGES ON DATABASE xcoin_db TO xcoin_user;
\q
```

### MySQL (Alternative)

```bash
# Auf dem Server:
mysql -u root -p

# In MySQL Shell:
CREATE DATABASE xcoin_db;
CREATE USER 'xcoin_user'@'localhost' IDENTIFIED BY 'your-secure-password';
GRANT ALL PRIVILEGES ON xcoin_db.* TO 'xcoin_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

## Schritt 3: .env.local erstellen

Erstelle eine `.env.local` Datei im Projekt-Root:

```env
# Database Configuration
DATABASE_URL="postgresql://xcoin_user:your-secure-password@localhost:5432/xcoin_db?schema=public"

# Oder für MySQL:
# DATABASE_URL="mysql://xcoin_user:your-secure-password@localhost:3306/xcoin_db"

# Next.js Configuration
NODE_ENV=production
NEXT_PUBLIC_SITE_URL=https://your-domain.com

# Email Configuration (optional - später für Email-Benachrichtigungen)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=your-email@example.com
SMTP_PASSWORD=your-password
SMTP_FROM=noreply@xcoin.ws
SMTP_TO=info@xcoin.ws

# Security (generiere mit: openssl rand -base64 32)
NEXTAUTH_SECRET=your-secret-key-here
NEXTAUTH_URL=https://your-domain.com
```

## Schritt 4: Prisma Schema anpassen (falls nötig)

Falls du MySQL statt PostgreSQL verwendest, ändere in `prisma/schema.prisma`:

```prisma
datasource db {
  provider = "mysql" // Statt "postgresql"
  url      = env("DATABASE_URL")
}
```

## Schritt 5: Datenbank-Migrationen ausführen

```bash
# Prisma Client generieren
npm run db:generate

# Datenbank-Schema erstellen (erste Migration)
npm run db:push

# Oder für Production (mit Migrationen):
npm run db:migrate
```

## Schritt 6: API-Routes aktivieren

### Contact Form API (`app/api/contact/route.ts`)

Entferne die Kommentare und aktiviere die Prisma-Integration:

```typescript
import { prisma } from "@/lib/prisma"

// In der POST-Funktion:
await prisma.contact.create({
  data: {
    name,
    email,
    message,
  }
})
```

### Validator Application API (`app/api/validator-application/route.ts`)

Entferne die Kommentare und aktiviere die Prisma-Integration:

```typescript
import { prisma } from "@/lib/prisma"

// In der POST-Funktion:
// Prüfen ob bereits eine Application existiert
const existingApplication = await prisma.validatorApplication.findFirst({
  where: {
    email: email,
    status: "pending"
  }
})
if (existingApplication) {
  return NextResponse.json(
    { error: "You already have a pending application" },
    { status: 400 }
  )
}

// Application speichern
await prisma.validatorApplication.create({
  data: {
    name,
    email,
    serverSpecs,
    connectionSpeed,
    location,
    status: "pending"
  }
})
```

## Schritt 7: Prisma Studio (optional)

Für Datenbank-Management:

```bash
npm run db:studio
```

Öffnet einen Browser auf `http://localhost:5555` mit einem GUI für die Datenbank.

## Schritt 8: Tests

### Contact Form testen

```bash
curl -X POST http://localhost:3000/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "message": "Test message"
  }'
```

### Validator Application testen

```bash
curl -X POST http://localhost:3000/api/validator-application \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Validator",
    "email": "validator@example.com",
    "serverSpecs": "4 CPU, 8GB RAM",
    "connectionSpeed": "100 Mbps",
    "location": "Berlin, Germany"
  }'
```

## Troubleshooting

### Prisma Client nicht gefunden

```bash
npm run db:generate
```

### Datenbank-Verbindungsfehler

1. Prüfe `.env.local` DATABASE_URL
2. Prüfe ob Datenbank läuft: `sudo systemctl status postgresql`
3. Prüfe Firewall-Regeln
4. Prüfe User-Berechtigungen

### Migration-Fehler

```bash
# Reset Datenbank (⚠️ Vorsicht: Löscht alle Daten!)
npx prisma migrate reset

# Oder nur Schema pushen
npm run db:push
```

## Production Checklist

- [ ] `.env.local` mit Production-Credentials erstellen
- [ ] DATABASE_URL auf Production-DB zeigen
- [ ] Prisma Client generiert: `npm run db:generate`
- [ ] Migrationen ausgeführt: `npm run db:migrate`
- [ ] API-Routes mit Prisma aktiviert
- [ ] Datenbank-Backups konfiguriert
- [ ] Monitoring eingerichtet

## Nächste Schritte

1. **Email-Integration**: Nodemailer oder Resend für E-Mail-Benachrichtigungen
2. **Rate Limiting**: Upstash Redis für API-Rate-Limiting
3. **Captcha**: Google reCAPTCHA oder hCaptcha für Spam-Schutz
4. **Monitoring**: Sentry oder ähnliches für Error-Tracking
5. **Backups**: Automatische Datenbank-Backups einrichten
