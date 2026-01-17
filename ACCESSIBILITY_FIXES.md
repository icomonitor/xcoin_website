# ♿ Accessibility Fixes

## Gefundene Probleme aus dem Audit:

1. ✅ **ARIA roles used must conform to valid values** - Prüfen und korrigieren
2. ✅ **Buttons must have discernible text** - aria-label vorhanden, aber prüfen
3. ✅ **Elements must have their visible text as part of their accessible name** - Links mit Icons prüfen
4. ⚠️ **Elements must meet minimum color contrast ratio thresholds** - CSS prüfen
5. ⚠️ **Heading levels should only increase by one** - Struktur korrigieren
6. ✅ **Alternative text of images should not be repeated as text** - alt-texts optimieren

## Fixes die ich anwende:

### 1. Heading-Struktur korrigieren
- Sicherstellen dass h1 → h2 → h3 (keine Sprünge)
- Visuelle "Headings" die keine semantischen Headings sind → korrigieren

### 2. Button-Texte
- Alle Buttons haben aria-label oder sichtbaren Text
- Menu-Button hat aria-label ✓

### 3. Color Contrast
- Prüfe text-muted-foreground vs background
- Prüfe accent colors

### 4. Image alt-texts
- Entferne redundante alt-texts wenn Text daneben steht
- Stelle sicher dass alle Images aussagekräftige alt-texts haben

### 5. ARIA Roles
- Prüfe alle role-Attribute
- Entferne ungültige roles
