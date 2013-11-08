#!/bin/bash

# montabk.sh
# Monta el disco de backups.
# queru@zaragozawireless.org

HD="/dev/TraciVG/backup"
DEST="/mnt/backup"

mount $HD $DEST &> /dev/null
if [ "$?" -eq 0 ]; then
	DF=`mount|grep $HD`
	echo "Disco de backup montado: $DF"
	exit 0
else
	DF=`mount|grep $HD`
	if [ "$?" -eq 0 ]; then
		echo "El disco ya estaba montado: $DF"
		exit 0
	else
		echo "Se ha producido un error!"
		exit 1
	fi
fi
