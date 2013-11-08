#!/bin/bash

if [[ "$1" == "" ]]
then
	echo "Utilización: $0 /punto_de_montaje"
	exit 1
fi

echo -e "Comprobando dispositivo $1...\c"
mount|grep "on $1" &> /dev/null
if [ $? -eq 0 ]
then
	echo "OK."
	exit 0
else
	echo "FALLO."
	exit 2
fi

