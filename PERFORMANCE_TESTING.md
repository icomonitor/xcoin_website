# 🚀 Performance Testing Guide

## Methoden zum lokalen Performance-Testen

### 1. Chrome DevTools Performance Tab (Empfohlen)

**Schritte:**
1. Starte die App im Production-Modus:
   ```bash
   pnpm build
   pnpm start
   ```

2. Öffne Chrome und gehe zu `http://localhost:3000`

3. Öffne Chrome DevTools:
   - `F12` oder `Cmd+Option+I` (Mac) / `Ctrl+Shift+I` (Windows)
   - Gehe zum Tab **Performance**

4. Performance aufzeichnen:
   - Klicke auf **Record** (roter Kreis)
   - Klicke auf einen Navigation-Link (z.B. "Learning")
   - Warte 2-3 Sekunden
   - Klicke auf **Stop**

5. Analysiere die Ergebnisse:
   - Suche nach **"Interaction"** Events
   - Prüfe **Input Delay**, **Processing Time**, **Presentation Delay**
   - Ziel: Input Delay < 40ms

### 2. Chrome DevTools Performance Monitor

**Schritte:**
1. Öffne Chrome DevTools (`F12`)
2. Gehe zu **More Tools** → **Performance Monitor**
3. Beobachte in Echtzeit:
   - CPU Usage
   - JS Heap Size
   - DOM Nodes
   - Event Listeners

4. Klicke auf Navigation-Links und beobachte die Werte

### 3. Lighthouse (Eingebaut in Chrome)

**Schritte:**
1. Öffne Chrome DevTools (`F12`)
2. Gehe zum Tab **Lighthouse**
3. Wähle:
   - ✅ Performance
   - ✅ Best Practices
   - Device: **Desktop** oder **Mobile**
4. Klicke auf **Analyze page load**
5. Prüfe die Metriken:
   - **First Contentful Paint (FCP)**
   - **Largest Contentful Paint (LCP)**
   - **Total Blocking Time (TBT)**
   - **Cumulative Layout Shift (CLS)**
   - **Speed Index**

### 4. Interaction Timing API (Programmatisch)

**Schritte:**
1. Öffne Chrome DevTools Console (`F12` → Console)
2. Führe diesen Code aus:

```javascript
// Performance Observer für Interaction Timing
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.entryType === 'event' && entry.name === 'click') {
      console.log('Interaction Timing:', {
        inputDelay: entry.processingStart - entry.startTime,
        processingTime: entry.processingEnd - entry.processingStart,
        presentationDelay: entry.duration - (entry.processingEnd - entry.startTime),
        total: entry.duration
      })
    }
  }
})

observer.observe({ entryTypes: ['event'] })

// Klicke jetzt auf einen Navigation-Link
```

### 5. Production Build lokal testen

**Wichtig:** Performance-Tests sollten immer im Production-Modus gemacht werden!

```bash
# Production Build erstellen
pnpm build

# Production Server starten
pnpm start

# Öffne http://localhost:3000
```

### 6. Web Vitals Messen

**Chrome Extension:**
- Installiere "Web Vitals" Extension von Chrome Web Store
- Öffne deine Seite
- Sieh dir die Web Vitals in der Extension an

**Oder programmatisch:**

```javascript
// In der Browser Console
import('https://unpkg.com/web-vitals@3/dist/web-vitals.umd.js').then(({ onCLS, onFID, onFCP, onLCP, onTTFB }) => {
  onCLS(console.log)
  onFID(console.log)
  onFCP(console.log)
  onLCP(console.log)
  onTTFB(console.log)
})
```

## Was du messen solltest:

### Interaction Timing:
- ✅ **Input Delay**: < 40ms (ideal), < 200ms (akzeptabel)
- ✅ **Processing Time**: < 50ms
- ✅ **Presentation Delay**: < 16ms (60fps)

### Core Web Vitals:
- ✅ **LCP** (Largest Contentful Paint): < 2.5s
- ✅ **FID** (First Input Delay): < 100ms
- ✅ **CLS** (Cumulative Layout Shift): < 0.1

## Vergleich: Vorher vs. Nachher

**Vorher (ohne Optimierungen):**
- Input Delay: ~154ms

**Nachher (mit Optimierungen):**
- Input Delay: Ziel < 100ms (idealerweise < 40ms)

## Tipps:

1. **Immer Production Build testen**: Dev-Modus ist langsamer
2. **CPU throttling aktivieren**: In DevTools → Performance → CPU: 4x slowdown
3. **Mehrfach testen**: Performance kann variieren, mache mehrere Tests
4. **Network throttling**: Simuliere langsame Verbindungen

## Troubleshooting:

### Performance ist immer noch schlecht:
- Prüfe ob Production Build läuft (`pnpm start`, nicht `pnpm dev`)
- Prüfe ob Browser-Cache geleert wurde
- Prüfe ob andere Extensions die Performance beeinflussen
- Teste im Incognito-Modus
