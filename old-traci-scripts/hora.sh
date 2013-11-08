#!/bin/bash

# hora.sh
# Pilla la hora de algún servidor horario de Internet.
# Si le falla uno prueba con el siguiente.
#
# Mejor no usar ya esto sino el ntpd.
#

TS="/usr/local/admin/time_servers.txt"

for i in `cat $TS`
do
	if [ "$1" = "-v" ]
	then 
		netdate tcp $i
	else
		netdate tcp $i &> /dev/null
	fi
	if [ $? -eq 0 ]
	then
		exit 0
	fi
done

echo "TODOS LOS SERVIDORES HORARIOS HAN FALLADO."
exit 1

