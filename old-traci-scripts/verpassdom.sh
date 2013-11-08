#!/bin/bash

source /etc/colores.sh

if [ $# -lt 1 ]
then
	echo "Utilización:"
	echo " "
	echo "	verpassdom.sh <dominio>"
else
	echo -e "\n"$BLANCO"------------------------------------------------------"
	echo -e "Dominio: $CYAN"$1$BLANCO
	echo -e "------------------------------------------------------"$NORMAL
	echo -e $AMARILLO"FTP: "$NORMAL
	PWD=$(echo "select name,pwd,uid,home from cqtraci.ftp where domain LIKE '%"$1"';" | mysql -t)
	if [ -z "$PWD" ]
	then
		echo -e $ROJO"No existe el dominio."$NORMAL
	else
		echo -e "$PWD"
	fi
	echo -e $AMARILLO"Administrador correo: "$NORMAL
	CORREO=$(echo "select * from cqtraci.domain_admins where domain LIKE '%"$1"%';" | mysql -t)
	if [ -z "$CORREO" ]
	then
		echo -e $ROJO" - No hay ningún admin para este dominio."$NORMAL
	else
		echo -e "$CORREO"
	fi
	echo -e $AMARILLO"Cuentas correo: "$NORMAL
	CORREO=$(echo "select username,password,name  from cqtraci.mailbox where domain LIKE '%"$1"%';" | mysql -t)
	if [ -z "$CORREO" ]
	then
		echo -e $ROJO" - No hay ningún admin para este dominio."$NORMAL
	else
		echo -e "$CORREO"
	fi
fi
echo " "
