#!/bin/bash

# desmontabk.sh
# Desmonta el disco de backups.
# queru@zaragozawireless.org

DEST="/mnt/backup"

umount $DEST
if [ "$?" -eq 0 ]; then
	echo "Disco de backup desmontado."
	exit 0
else
	echo "¡Se ha producido un error!"
	exit 1
fi
