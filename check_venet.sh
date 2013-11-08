#!/bin/bash

# Configuración:
LOG="/var/log/check_venet.log"

# Funciones:
function log {
	echo $1
	echo "[$(date +"%d%m%Y@%H%M%S")] ${1}" >> $LOG
}

function network_restart {
	log "Reiniciando networking"
	/etc/init.d/networking restart
}

function shore_restart {
	log "Reiniciando shorewall"
	/etc/init.d/shorewall restart
}

# Comprobación:
ip l|grep venet0 &> /dev/null
if [ $? -ne 0 ]
then
	log "No existe interfaz venet0."
	network_restart
	shore_restart
	exit 1
fi

ip a l dev venet0|grep "192.168.100.254/22" &> /dev/null
if [ $? -ne 0 ]
then
	log "Interfaz venet0 no tiene IP."
	network_restart
	shore_restart
	exit 1
fi

exit 0

