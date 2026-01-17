# 🔐 Vercel Environment Variables Setup

## ✅ Aktuelle Konfiguration in Vercel

Du hast bereits folgende Environment Variables gesetzt:
- ✅ `PRISMA_DATABASE_URL` - Prisma Accelerate URL (für Production optimiert)
- ✅ `DATABASE_URL` - Direkte PostgreSQL-Verbindung
- ✅ `POSTGRES_URL` - Direkte PostgreSQL-Verbindung

## 🔧 Optimale Konfiguration

Für die beste Performance sollte `DATABASE_URL` die Prisma Accelerate URL sein:

### 1. DATABASE_URL (Sollte Prisma Accelerate sein)

**Aktuell**: Direkte PostgreSQL-Verbindung  
**Sollte sein**: Prisma Accelerate URL

**Ändere `DATABASE_URL` zu:**
```
prisma+postgres://accelerate.prisma-data.net/?api_key=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqd3RfaWQiOjEsInNlY3VyZV9rZXkiOiJza19BSGd2RjJhRTRjbFlHRUdqYVFkT0IiLCJhcGlfa2V5IjoiMDFLRjYxSllGREpTWUZKWlg2MTNOQVZFMkciLCJ0ZW5hbnRfaWQiOiJhOGRjZTM3ZTgyY2I4YWM0MDRiZjA0YTJlM2Q5ZWYxNjE1YzliYmM3YjEwZmYwNzZkMzY2MTVlNTA0Yjg1ZDYzIiwiaW50ZXJuYWxfc2VjcmV0IjoiMzM0ZGY3YWEtODlmNS00Nzc4LWFkOTgtZWQ2ZGViZGRlYjM2In0.tyyq8VEe8IHl_ethGH6QSCkyUAnvgniWU1QwmNNCdwk
```

### 2. DIRECT_URL (Für Migrationen - Neu hinzufügen)

**Name**: `DIRECT_URL`  
**Value**: 
```
postgres://a8dce37e82cb8ac404bf04a2e3d9ef1615c9bbc7b10ff076d36615e504b85d63:sk_AHgvF2aE4clYGEGjaQdOB@db.prisma.io:5432/postgres?sslmode=require
```
**Environment**: ✅ Production, ✅ Preview, ✅ Development

**Hinweis**: `DIRECT_URL` wird nur für Migrationen benötigt. Prisma Accelerate verwendet `DATABASE_URL` für normale Queries.

### 3. Bestehende Variablen (können bleiben)

- `PRISMA_DATABASE_URL` - Kann bleiben (falls von anderen Tools verwendet)
- `POSTGRES_URL` - Kann bleiben (falls von anderen Tools verwendet)

## Nach dem Setup

1. **Migrationen ausführen**:
   ```bash
   # Lokal (mit DIRECT_URL):
   npx prisma migrate deploy
   
   # Oder mit db push (für schnelles Setup):
   npx prisma db push
   ```

2. **Prisma Client generieren**:
   ```bash
   npx prisma generate
   ```

3. **Deploy auf Vercel**:
   - Vercel führt automatisch `prisma generate` während des Builds aus
   - Die Datenbankverbindung wird automatisch verwendet

## Prisma Accelerate Vorteile

- ✅ **Connection Pooling**: Optimiert für Serverless-Umgebungen
- ✅ **Bessere Performance**: Reduzierte Latenz durch Caching
- ✅ **Automatisches Scaling**: Passt sich an Traffic an
- ✅ **Monitoring**: Eingebautes Monitoring in Prisma Dashboard

## Troubleshooting

### Migrationen schlagen fehl

Wenn Migrationen mit Prisma Accelerate fehlschlagen, verwende `DIRECT_URL`:

```bash
# Temporär DIRECT_URL setzen
export DIRECT_URL="postgres://a8dce37e82cb8ac404bf04a2e3d9ef1615c9bbc7b10ff076d36615e504b85d63:sk_AHgvF2aE4clYGEGjaQdOB@db.prisma.io:5432/postgres?sslmode=require"

# Migrationen ausführen
npx prisma migrate deploy
```

### Datenbankverbindung funktioniert nicht

1. Prüfe, ob `DATABASE_URL` in Vercel gesetzt ist
2. Stelle sicher, dass alle Environments (Production, Preview, Development) ausgewählt sind
3. Prüfe Prisma Dashboard für Connection-Status
