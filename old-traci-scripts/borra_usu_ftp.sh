#!/bin/bash

# Borra un usuario de FTP:

source /usr/local/admin/colores.inc

echo -e $CYAN"\n+ BAJA DE USUARIO FTP:\n"$NORMAL

if [ -z "$1" ]
then
	echo -e "    - "$VERDE"Usuario:"$BLANCO" \c"
	read USU
else
echo -e "    - "$VERDE"Usuario: "$BLANCO$1
USU=$1
fi

if [ -z "$USU" ]
then
echo -e $ROJO"\n¡Usuario vacío!$NORMAL\n"
exit 1
fi

DATOS=$(echo "select * from cqtraci.ftp where name='$USU';"|mysql)
if [ -z "$DATOS" ]
then
	echo -e $ROJO"\nEl usuario no existe.\n"$NORMAL
	exit 1
fi

echo -e "\n"$BLANCO"> "$AMARILLO"Datos de $USU$NORMAL"
echo "select * from cqtraci.ftp where name='$USU';"|mysql -t

echo -e "\n"$BLANCO"    - "$VERDE"¿Confirma que desea borrar este usuario? (s/N): "$BLANCO"\c"
read -n1 SINO
if [ "$SINO" == "S" ]
then
	SINO="s"
fi
if [ "$SINO" != "s" ]
then
	echo -e $AMARILLO"\n\n*** ABORTADO ***\n"$NORMAL
	exit 1
fi
	
echo -e "\n"$BLANCO"    > "$VERDE"Borrando usuario $BLANCO$USU$NORMAL..."
echo "DELETE FROM cqtraci.ftp WHERE name='$USU' LIMIT 1;"|mysql

echo -e $AZUL"\n> Finalizado.\n"$NORMAL

