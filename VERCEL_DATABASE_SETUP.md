# 🚀 Vercel Datenbank-Setup für Xcoin Website

## Übersicht

Die Contact- und Validator-Application-Seiten sind jetzt mit Prisma verbunden und speichern Daten in der Datenbank.

## Schritt 1: Datenbank auf Vercel einrichten

### Option A: Vercel Postgres (Empfohlen)

1. Gehe zu deinem Vercel-Projekt Dashboard
2. Navigiere zu **Settings** → **Storage**
3. Klicke auf **Create Database** → **Postgres**
4. Wähle einen Namen für deine Datenbank (z.B. `xcoin-db`)
5. Wähle eine Region (z.B. `Frankfurt (fra1)` für bessere Performance in Europa)
6. Klicke auf **Create**

### Option B: Externe Datenbank (z.B. Supabase, Neon, Railway)

1. Erstelle eine PostgreSQL-Datenbank bei deinem Provider
2. Kopiere die Connection String (DATABASE_URL)

## Schritt 2: Environment Variables in Vercel konfigurieren

1. Gehe zu deinem Vercel-Projekt Dashboard
2. Navigiere zu **Settings** → **Environment Variables**
3. Füge folgende Variable hinzu:

### Für Vercel Postgres:
- **Name**: `DATABASE_URL`
- **Value**: Wird automatisch von Vercel gesetzt (nachdem du die Datenbank erstellt hast)
- **Environment**: Production, Preview, Development (alle auswählen)

### Für externe Datenbank:
- **Name**: `DATABASE_URL`
- **Value**: `postgresql://user:password@host:5432/database?schema=public`
- **Environment**: Production, Preview, Development (alle auswählen)

## Schritt 3: Prisma Migrationen auf Vercel ausführen

### Automatisch (empfohlen):

Vercel führt automatisch `prisma generate` während des Builds aus (siehe `package.json`):

```json
{
  "scripts": {
    "postinstall": "prisma generate",
    "build": "prisma generate && next build"
  }
}
```

### Manuell (falls nötig):

1. Installiere Vercel CLI:
```bash
npm i -g vercel
```

2. Führe Migrationen aus:
```bash
# Lokal mit Vercel Environment Variables
vercel env pull .env.local
npx prisma migrate deploy
```

Oder direkt auf Vercel:
```bash
vercel --prod
```

## Schritt 4: Datenbank-Schema erstellen

### Option 1: Mit Prisma Migrate (empfohlen für Production)

```bash
# Lokal: Migration erstellen
npx prisma migrate dev --name init

# Auf Vercel: Migrationen anwenden
# Wird automatisch beim Build ausgeführt, oder manuell:
npx prisma migrate deploy
```

### Option 2: Mit Prisma DB Push (für schnelles Setup)

```bash
npx prisma db push
```

**Wichtig**: `db push` ist für Development. Für Production sollte `migrate` verwendet werden.

## Schritt 5: Build Command anpassen (falls nötig)

Die `vercel.json` ist bereits konfiguriert:

```json
{
  "buildCommand": "pnpm run build"
}
```

Das `build` Script in `package.json` führt bereits `prisma generate` aus.

## Schritt 6: Testen

### 1. Contact Form testen:

```bash
curl -X POST https://your-domain.vercel.app/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "message": "Test message"
  }'
```

### 2. Validator Application testen:

```bash
curl -X POST https://your-domain.vercel.app/api/validator-application \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Validator",
    "email": "validator@example.com",
    "serverSpecs": "4 CPU, 8GB RAM",
    "connectionSpeed": "100 Mbps",
    "location": "Berlin, Germany"
  }'
```

## Schritt 7: Datenbank-Daten ansehen

### Mit Vercel Postgres:

1. Gehe zu **Storage** → **Postgres** → **Data**
2. Du kannst die Tabellen `contacts` und `validator_applications` sehen

### Mit Prisma Studio (lokal):

```bash
# Environment Variables von Vercel holen
vercel env pull .env.local

# Prisma Studio starten
npx prisma studio
```

Öffnet einen Browser auf `http://localhost:5555`

## Troubleshooting

### Fehler: "Prisma Client not found"

**Lösung**: Stelle sicher, dass `prisma generate` im Build-Prozess ausgeführt wird:

```json
{
  "scripts": {
    "postinstall": "prisma generate",
    "build": "prisma generate && next build"
  }
}
```

### Fehler: "Can't reach database server"

**Lösung**: 
1. Prüfe die `DATABASE_URL` in Vercel Environment Variables
2. Stelle sicher, dass die Datenbank läuft
3. Prüfe Firewall-Regeln (bei externen Datenbanken)

### Fehler: "Table does not exist"

**Lösung**: Führe Migrationen aus:

```bash
npx prisma migrate deploy
```

Oder mit `db push`:

```bash
npx prisma db push
```

### Fehler: "Unique constraint violation"

**Lösung**: Das ist normal - die Validator Application API prüft bereits auf doppelte E-Mails. Eine E-Mail kann nur eine pending Application haben.

## Wichtige Hinweise

1. **DATABASE_URL**: Muss in allen Environments (Production, Preview, Development) gesetzt sein
2. **Migrationen**: Werden automatisch beim Build ausgeführt, wenn `prisma generate` im Build-Script ist
3. **Connection Pooling**: Vercel Postgres verwendet automatisch Connection Pooling
4. **Backups**: Vercel Postgres erstellt automatisch Backups. Bei externen Datenbanken musst du selbst Backups einrichten

## Nächste Schritte

- [ ] Email-Benachrichtigungen einrichten (z.B. mit Resend)
- [ ] Rate Limiting hinzufügen (z.B. mit Upstash Redis)
- [ ] Captcha für Spam-Schutz (z.B. hCaptcha)
- [ ] Monitoring einrichten (z.B. Sentry)
