#!/bin/bash

# Comprueba que dominios hay todavía en osiris y
# que no estén en traci.

ls -C1 --color=none /web/domains > doms_traci.txt

for i in $(cat doms_osiris_fin.txt)
do
	cat doms_traci.txt|egrep "^$i" &> /dev/null
	if [ $? -ne 0 ]
	then
		echo $i
	fi
done

