#!/bin/bash

# Desactivar un dominio.
# Normalmente por falta de pago.

source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"+ DESACTIVAR DOMINIO WEB:\n"$NORMAL

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

echo -e $CYAN"\n¿Confirma desactivación de dominio $DOM? (S/n):"$BLANCO" \c"
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

echo -e $BLANCO"> Realizando copia de seguridad a /web/desactivados...\c"$NORMAL
mkdir -p /web/desactivados &> /dev/null
tar -cjpf /web/desactivados/$DOM-$(date +"%s").tar.bz2 /web/domains/$DOM &> /dev/null
echo -e $VERDE"OK"$NORMAL

echo -e $BLANCO"> Borrando web...\c"$NORMAL
rm -Rf /web/domains/$DOM &> /dev/null
echo -e $VERDE"OK"$NORMAL

echo -e $BLANCO"> Creando web con índice de desactivado...\c"$NORMAL
mkdir -p /web/domains/$DOM/htdocs &> /dev/null
cp /web/default/desactivado.php /web/domains/$DOM/htdocs/index.php
echo -e $VERDE"OK"$NORMAL

echo -e $BLANCO"> Desactivando usuarios FTP...\c"$NORMAL
echo "UPDATE cqtraci.ftp SET activo='no' WHERE domain='$DOM';" | mysql
echo -e $VERDE"OK"$NORMAL

