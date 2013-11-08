#!/bin/bash

source /etc/colores.sh

if [ $# -lt 1 ]
then
	echo "Utilización:"
	echo " "
	echo "	existe_dom.sh <dominio>"
else
	echo -e "\n"$BLANCO"------------------------------------------------------"
	echo -e "Dominio: $CYAN"$1$BLANCO
	echo -e "------------------------------------------------------"$NORMAL
	echo -e $AMARILLO"FTP: \c"
	PWD=$(echo "select name,pwd,home from cqtraci.ftp where domain LIKE '%"$1"';" | mysql -t)
	if [ -z "$PWD" ]
	then
		echo -e $ROJO"No existe el dominio."$NORMAL
	else
		echo -e $VERDE"Existe."$NORMAL
	fi
	echo -e $AMARILLO"Correo: \c"
	CORREO=$(echo "select domain from cqtraci.domain where domain='"$1"';" | mysql -t)
	if [ -z "$CORREO" ]
	then
		echo -e $ROJO" - No hay ningún admin para este dominio."$NORMAL
	else
		echo -e $VERDE"Existe."$NORMAL
	fi
fi
echo " "
