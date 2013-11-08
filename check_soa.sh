#!/bin/bash

source /usr/local/admin/include/funciones.inc.sh

LOG="/var/log/no-soa.log"
FALLOS=0
cat /dev/null > $LOG

titulo "Comprobando zonas DNS"

for i in $(ls -C1 /vz/private/103/tinydns/root/dominios-traci.es)
do
	echo -en "${VERDE}>${NORMAL} $i..."
	# SOA:
	dig $i soa|grep -E "IN.*SOA.*ns.\.traci\.es" &> /dev/null
	if [ $? -eq 0 ]
	then
		echo -e "${VERDE}OK${NORMAL}"
	else
		let FALLOS++
		echo -e "${ROJO}FALLO${NORMAL}"
		echo "- $i: Fallo en SOA" >> $LOG
	fi
done

if [ $FALLOS > 0 ]
then
	echo > /dev/stderr
	echo "+++ $FALLOS FALLOS DETECTADOS +++" > /dev/stderr
	cat $LOG > /dev/stderr
	exit 1
else
	echo
	echo -e "> Todo ${VERDE}correcto${NORMAL}."
	exit 0
fi

