#!/bin/bash

source /usr/local/admin/colores.inc

echo -e $CYAN"+ ALTA DE DOMINIO DNS:\n"

if [ -z "$1" ]
then
	echo -e $ROJO"    - ERROR: Debe indicar el nombre del dominio, sin www."$NORMAL
	exit 1
fi

echo -e $VERDE"    - Dominio: "$BLANCO$1$NORMAL"\n"
rcdjbdns wdom $1 194.143.194.244
echo " "

