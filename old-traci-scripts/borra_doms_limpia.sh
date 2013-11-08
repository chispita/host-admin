#!/bin/bash

source include/colores.inc.sh

for i in $(cat doms_borrar.txt)
do
	echo -e $VERDE">"$NORMAL" Dominio "$CYAN$i$NORMAL": \c"
	if [ -f /vz/private/102/tinydns/root/dominios-traci.es/$i ]
	then
		echo " "
		whois $i|egrep -i "^Name Server"
		echo -e "+ Borrar"$AMARILLO"?"$NORMAL"\c"
		read SN
		if [ "$SN" == "s" ]
		then
			echo -e "+ "$ROJO"Borrando"$NORMAL" "$CYAN$i$NORMAL"...\c"
			rm -f /vz/private/102/tinydns/root/dominios-traci.es/$i
			echo -e $VERDE"OK"$NORMAL"."
			echo " "
		fi
	else
		echo -e $ROJO"No existe"$NORMAL"."
	fi
done
