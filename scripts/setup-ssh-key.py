#!/usr/bin/env python3
"""SSH-Key auf Server kopieren mit pexpect"""

import pexpect
import os
import sys

HOST = "82.221.100.116"
USER = "Xcoin"
PASSWORD = "FLduSONDedfRfsw52g3jfD93SsFfs!"

# Public Key lesen
home = os.path.expanduser("~")
pubkey_path = os.path.join(home, ".ssh", "id_rsa.pub")

try:
    with open(pubkey_path, "r") as f:
        pubkey = f.read().strip()
except FileNotFoundError:
    print(f"Fehler: {pubkey_path} nicht gefunden!")
    sys.exit(1)

print(f"SSH-Key wird auf Server {USER}@{HOST} kopiert...")

# SSH-Verbindung herstellen
try:
    child = pexpect.spawn(f"ssh -o StrictHostKeyChecking=no {USER}@{HOST}", timeout=30, encoding='utf-8')
    
    # Mögliche Prompts abfangen
    index = child.expect(['password:', 'yes/no', pexpect.EOF, pexpect.TIMEOUT], timeout=10)
    
    if index == 1:  # yes/no
        child.sendline("yes")
        child.expect('password:')
        child.sendline(PASSWORD)
    elif index == 0:  # password
        child.sendline(PASSWORD)
    elif index == 2:  # EOF - bereits verbunden?
        print("Bereits verbunden oder unerwartete Antwort")
        sys.exit(1)
    elif index == 3:  # TIMEOUT
        print("Timeout - Server antwortet nicht")
        sys.exit(1)
    
    # Warten auf Prompt
    child.expect(r'\$ |# ')
    
    # .ssh Verzeichnis erstellen
    print("Erstelle .ssh Verzeichnis...")
    child.sendline("mkdir -p ~/.ssh && chmod 700 ~/.ssh")
    child.expect(r'\$ |# ')
    
    # Prüfen ob Key bereits existiert
    print("Prüfe ob Key bereits existiert...")
    child.sendline(f"grep -F '{pubkey}' ~/.ssh/authorized_keys 2>/dev/null || echo 'KEY_NOT_FOUND'")
    child.expect(r'\$ |# ')
    output = child.before
    
    if "KEY_NOT_FOUND" in output or pubkey not in output:
        # Key hinzufügen
        print("Füge SSH-Key hinzu...")
        child.sendline(f"echo '{pubkey}' >> ~/.ssh/authorized_keys")
        child.expect(r'\$ |# ')
        
        # Permissions setzen
        print("Setze Berechtigungen...")
        child.sendline("chmod 600 ~/.ssh/authorized_keys")
        child.expect(r'\$ |# ')
        
        print("✅ SSH-Key erfolgreich kopiert!")
    else:
        print("✅ SSH-Key existiert bereits!")
    
    # Verbindung testen
    print("Teste SSH-Verbindung...")
    child.sendline("exit")
    child.expect(pexpect.EOF)
    child.close()
    
    # Test-Verbindung ohne Passwort
    print("\nTeste passwortlose Verbindung...")
    test = pexpect.spawn(f"ssh -o StrictHostKeyChecking=no {USER}@{HOST} 'echo SSH_KEY_WORKS'", timeout=10, encoding='utf-8')
    test.expect(pexpect.EOF)
    output = test.before
    
    if "SSH_KEY_WORKS" in output:
        print("✅ Passwortlose SSH-Verbindung funktioniert!")
        sys.exit(0)
    else:
        print("⚠️  Verbindung funktioniert möglicherweise noch nicht")
        print(f"Output: {output}")
        sys.exit(1)
        
except pexpect.TIMEOUT:
    print("❌ Timeout - Server antwortet nicht")
    sys.exit(1)
except pexpect.EOF:
    print("❌ Verbindung wurde geschlossen")
    sys.exit(1)
except Exception as e:
    print(f"❌ Fehler: {e}")
    sys.exit(1)
