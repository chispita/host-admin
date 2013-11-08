#!/bin/bash

source /usr/local/admin/include/colores.inc.sh

rm -f doms_borrar.txt
rm -f doms_es.txt
rm -f doms_guardar.txt

for i in $(ls -C1 /vz/private/102/tinydns/root/dominios-traci.es)
do
	echo -e $VERDE">"$NORMAL" Comprobando "$CYAN$i$NORMAL"...\c"
	echo $i |egrep "\.es$" &> /dev/null
	if [ $? -eq 0 ]
	then
		echo "(.es)"
		echo $i >> doms_es.txt
	else
		whois $i |egrep -i "ns.\.qaop\.com|ns.\.traci\.es|ns.\.queru\.org" &> /dev/null
		if [ $? -eq 0 ]
		then
			echo -e $VERDE"OK"$NORMAL
			echo $i >> doms_guardar.txt
		else
			echo -e $ROJO"FALSO"$NORMAL
			echo $i >> doms_borrar.txt
		fi
	fi
done

echo "Los dominios a borrar se han guardado en doms_borrar.txt."
echo " "
