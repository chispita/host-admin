#!/bin/bash

HOSTNAME=$(hostname)

function log {
	FECHA=$(date +"%d-%m-%Y@%H:%M:%S")
	echo $1
	echo "[${FECHA}] ${1}" >> /var/log/apt-mirror-sh.log
}

if [ $HOSTNAME == "nodo1" ]
then
	log "Iniciando apt-mirror."
	apt-mirror
	if [ $? -eq 0 ]
	then
		log "Finalizado OK."
	else
		log "Finalizado con ERROR."
	fi
	log "Limpiando."
	/backup/apt-mirror/var/clean.sh
	if [ $? -eq 0 ]
	then
		log "Limpieza OK."
	else
		log "ERROR ejecutando /backup/apt-mirror/var/clean.sh."
	fi
else
	log "ERROR($HOSTNAME): Sólo se puede hacer el mirror desde nodo1."
	exit 1
fi
