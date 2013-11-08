#!/bin/bash

source /etc/colores.sh

if [ $# -lt 2 ]
then
	echo "Utilización:"
	echo " "
	echo "	cambiapassdom.sh <usuario_dom> <contraseña>"
	echo " "
else
	USU=$1
	echo $USU|grep -E "www+\.[-a-zA-Z0-9]+\.[-a-zA-Z0-9]+*" &> /dev/null
	if [ $? -eq 0 ]
	then
        	echo -e $ROJO"No teclee dominios sino usuarios sin puntos."$NORMAL
        	exit 1
	fi

	echo $USU|grep -E "[-a-zA-Z0-9]+\.[-a-zA-Z0-9]+*" &> /dev/null
	if [ $? -eq 0 ]
	then
        	echo $ROJO"Los usuarios no llevan puntos. Por ej: viernes_org"$NORMAL
	fi

	echo -e $BLANCO"------------------------------------------------------"
	echo -e "Dominio: $CYAN"$USU$BLANCO
	echo -e "------------------------------------------------------"$NORMAL
	echo -e $AMARILLO"Pass FTP actual: "$NORMAL
	echo "select domain,pwd from cqtraci.ftp where name = '"$USU"';" | mysql -t
	echo -e "Ajustando pass a "$BLANCO$2$NORMAL"..."
	echo "update cqtraci.ftp set pwd='"$2"' where name='"$USU"' limit 1;" | mysql
	echo "select domain,pwd from cqtraci.ftp where name = '"$USU"';" | mysql -t
	echo -e $VERDE"Finalizado."$NORMAL
fi
