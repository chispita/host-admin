#!/bin/bash

source /usr/local/admin/include/colores.inc.sh

DNS="188.40.101.251, 194.143.194.93, 194.143.194.94"
for i in $(echo $DNS|tr -d ","|tr " " "\n")
do
	echo -e $VERDE">"$NORMAL" Comprobando servidor DNS "$AMARILLO$i$NORMAL"...\c"
	dig @$i queru.org mx &> /dev/null
	if [ $? -eq 0 ]
	then
		echo -e $VERDE"OK"$NORMAL
	else
		echo -e $ROJO"FALLO"$NORMAL
	fi
done

