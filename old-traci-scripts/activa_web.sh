#!/bin/bash

# Activar un dominio.
# Normalmente por que ha vuelto a pagar.

source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"+ REACTIVAR DOMINIO WEB:\n"$NORMAL

if [ -z "$1" ]
then
	echo -e "    - "$VERDE"Dominio:"$BLANCO" \c"
	read DOM
else
	echo -e "    - "$VERDE"Dominio: "$BLANCO$1
	DOM=$1
fi

if [ -z "$DOM" ]
then
	echo -e $AMARILLO"\n*** ABORTADO ***\n"$NORMAL
	exit 1
fi

BACKUPS=$(ls -C1 /web/desactivados/$DOM*.tar.bz2 2> /dev/null)
if [ "$BACKUPS" = "" ]
then
	echo -e $ROJO"\nNo existe ninguna web desactivada de $DOM.\n"$NORMAL
	exit 1
fi

echo -e $CYAN"\n¿Confirma reactivación de dominio $DOM? (S/n):"$BLANCO" \c"
read -n1 SINO
if [ -z "$SINO" ]
then
	SINO="s"
fi
if [ "$SINO" == "S" ]
then
	SINO="s"
fi
if [ "$SINO" != "s" ]
then
	echo -e $AMARILLO"\n*** ABORTADO ***\n"$NORMAL
	exit 1
fi

echo " "

echo -e $BLANCO"> Borrando web desactivada...\c"$NORMAL
rm -Rf /web/domains/$DOM &> /dev/null
echo -e $VERDE"OK"$NORMAL

echo -e $BLANCO"> Restaurando copia de seguridad de /web/desactivados:"$NORMAL
echo -e $BLANCO"  - Buscando backup..."$NORMAL
for i in $BACKUPS
do
	FIC=$(basename $i)
	echo -e $VERDE "    $FIC"$NORMAL
done
echo -e $BLANCO"  - Último backup: $FIC...Restaurando...\c"$NORMAL
tar -xjpf /web/desactivados/$FIC -C /
echo -e $VERDE"OK"$NORMAL

echo -e $BLANCO"> Reactivando usuarios FTP...\c"$NORMAL
echo "UPDATE cqtraci.ftp SET activo='si' WHERE domain='$DOM';" | mysql
echo -e $VERDE"OK"$NORMAL

echo -e $CYAN"> Finalizado.\n"$NORMAL
