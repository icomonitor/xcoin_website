#!/bin/bash

# Performance Testing Script
# Führt Production Build aus und startet Server für Performance-Tests

echo "🚀 Performance Testing Setup"
echo "============================"
echo ""

# Prüfe ob Node.js installiert ist
if ! command -v node &> /dev/null; then
    echo "❌ Node.js ist nicht installiert"
    exit 1
fi

# Prüfe ob pnpm installiert ist
if ! command -v pnpm &> /dev/null; then
    echo "⚠️  pnpm nicht gefunden, verwende npm..."
    PACKAGE_MANAGER="npm"
else
    PACKAGE_MANAGER="pnpm"
fi

echo "📦 Erstelle Production Build..."
$PACKAGE_MANAGER run build

if [ $? -ne 0 ]; then
    echo "❌ Build fehlgeschlagen!"
    exit 1
fi

echo ""
echo "✅ Build erfolgreich!"
echo ""
echo "🌐 Starte Production Server..."
echo ""
echo "📊 Öffne http://localhost:3000 in Chrome"
echo ""
echo "🔍 Performance testen:"
echo "   1. Öffne Chrome DevTools (F12)"
echo "   2. Gehe zum Tab 'Performance'"
echo "   3. Klicke auf 'Record'"
echo "   4. Klicke auf einen Navigation-Link"
echo "   5. Klicke auf 'Stop'"
echo "   6. Analysiere 'Interaction Timing'"
echo ""
echo "💡 Tipp: Verwende auch Lighthouse für detaillierte Metriken"
echo ""
echo "⏹️  Drücke Ctrl+C zum Beenden"
echo ""

$PACKAGE_MANAGER start
