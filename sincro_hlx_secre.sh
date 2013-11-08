#!/bin/bash

# Sincroniza la BDD de secretaría de Hispalinux.

FECHA=$(date +"%d%b%G")
OUT="hispalinux_secre-${FECHA}.sql.bz2"
echo -e "Exportando hispalinux_secre...\c"
mysqldump --add-drop-table hispalinux_secre |bzip2 > /root/$OUT
echo "OK"
echo "Enviando a secretaria.hispalinux.es..."
scp -P11022 -o "StrictHostKeyChecking no" /root/$OUT root@pound.hispalinux.es:/root/.
echo "OK"
echo "Inyectando en la BDD..."
ssh -p 11022 -o "StrictHostKeyChecking no" root@pound.hispalinux.es "bzcat /root/$OUT | mysql secretaria"
ssh -p 11022 -o "StrictHostKeyChecking no" root@pound.hispalinux.es "rm /root/$OUT"
echo "Finalizado"

