#!/bin/bash

source /usr/local/admin/include/colores.inc.sh

RSYNC="/usr/bin/rsync -aE --recursive --no-relative --stats --delete --delete-excluded"
HOSTDESTINO="root@172.20.0.254"
HOST=$(hostname)
DIRDESTINO="/backup/"$HOST"-rsync"
SRC="/"
EXCLUDE="/usr/local/admin/general_backup_excludes.txt"
LOG="/var/log/last_backup.log"
INICIO=$(date)
HOSTNAME=$(hostname -f)
SEPARADOR="================================================"

echo -e $CYAN"+++ BackUp general de $HOSTNAME +++"$NORMAL
echo -e $VERDE">"$NORMAL" Creando dir destino..."
ssh $HOSTDESTINO mkdir -p $DIRDESTINO
echo -e $VERDE">"$NORMAL" Comenzando rsync contra "$AMARILLO$HOSTDESTINO$NORMAL"..."
echo -e $AZUL"El resultado se guardara en $LOG"$NORMAL
$RSYNC --exclude-from=${EXCLUDE} ${SRC} ${HOSTDESTINO}:${DIRDESTINO} &> $LOG.tmp
echo -e "\nRESULTADO: $?" >> $LOG.tmp

# Componer log:
echo "BACKUP por rsync:" > $LOG
echo $SEPARADOR
echo "INICIO: $INICIO" >> $LOG
echo "Comando rsync:" >> $LOG
echo $RSYNC \\ >> $LOG
echo "    "--exclude-from=${EXCLUDE} \\ >> $LOG
echo "    "${SRC} ${HOSTDESTINO}:${DIRDESTINO} >> $LOG
echo -e "\n\nSALIDA:" >> $LOG
cat $LOG.tmp >> $LOG
rm $LOG.tmp
echo -e $SEPARADOR"\nFINAL: "$(date)".\n" >> $LOG

cat $LOG
echo -e $VERDE"\n+++ FINALIZADO +++\n"$NORMAL

