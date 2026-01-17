#!/bin/bash

# Einfaches automatisches SSH-Setup - mit besserem Error Handling

HOST="82.221.100.116"
USER="Xcoin"
PASSWORD="FLduSONDedfRfsw52g3jfD93SsFfs!"
PUBKEY=$(cat ~/.ssh/id_rsa.pub)

echo "🔑 Automatisches SSH-Key Setup..."
echo ""

# Erstelle temporäres expect-Script
TMP_EXPECT=$(mktemp /tmp/ssh-setup.XXXXXX)
cat > "$TMP_EXPECT" << EOF
#!/usr/bin/expect -f
set timeout 15
spawn ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 $USER@$HOST "bash -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo \"$PUBKEY\" >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && echo SUCCESS'"

expect {
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    "password:" {
        send "$PASSWORD\r"
        exp_continue
    }
    "SUCCESS" {
        puts "\n✅ SSH-Key erfolgreich kopiert!"
        exit 0
    }
    timeout {
        puts "\n❌ Timeout - Server antwortet nicht"
        exit 1
    }
    eof {
        puts "\n⚠️  Verbindung geschlossen"
        exit 1
    }
}
EOF

chmod +x "$TMP_EXPECT"
"$TMP_EXPECT"
RESULT=$?

rm -f "$TMP_EXPECT"

if [ $RESULT -eq 0 ]; then
    echo ""
    echo "Teste passwortlose Verbindung..."
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 $USER@$HOST "echo '✅ Passwortlose SSH-Verbindung funktioniert!'" 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Setup erfolgreich abgeschlossen!"
        exit 0
    else
        echo "⚠️  Verbindung funktioniert noch nicht - warte 5 Sekunden und versuche erneut..."
        sleep 5
        ssh -o StrictHostKeyChecking=no $USER@$HOST "echo '✅ Test erfolgreich!'" 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ Setup erfolgreich abgeschlossen!"
            exit 0
        else
            echo "⚠️  Bitte manuell testen: ssh $USER@$HOST"
            exit 1
        fi
    fi
else
    echo ""
    echo "❌ Automatisches Setup fehlgeschlagen"
    echo "Bitte führe manuell aus: ./scripts/manual-ssh-setup.sh"
    exit 1
fi
