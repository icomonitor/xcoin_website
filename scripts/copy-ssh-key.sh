#!/bin/bash

# SSH-Key auf Server kopieren mit expect

HOST="82.221.100.116"
USER="Xcoin"
PASSWORD="FLduSONDedfRfsw52g3jfD93SsFfs!"
PUBKEY=$(cat ~/.ssh/id_rsa.pub)

expect << EOF
spawn ssh -o StrictHostKeyChecking=no ${USER}@${HOST} "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '${PUBKEY}' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

expect {
    "yes/no" {
        send "yes\r"
        exp_continue
    }
    "password:" {
        send "${PASSWORD}\r"
    }
    eof
}

expect eof
EOF

echo "SSH-Key kopiert! Teste Verbindung..."
ssh -o StrictHostKeyChecking=no ${USER}@${HOST} "echo 'SSH-Verbindung erfolgreich!'"
