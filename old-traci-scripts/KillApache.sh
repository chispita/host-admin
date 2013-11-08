#!/bin/bash

# Se cepilla todo lo que quede escuchando.

source /usr/local/admin/colores.inc

echo -e $BLANCO"> Matando todo lo que quede escuchando en http/https..."$NORMAL
sleep 3
for proceso in $(lsof -i 2> /dev/null|egrep "(apache|http|https|\:443]).*\(LISTEN\)"|tr -s " "|cut -f2 -d" ")
do
	echo -e $ROJO"- Matando proceso "$proceso":"$NORMAL"\c"
	if [ $? -eq 0 ]
	then
		kill -9 $proceso &> /dev/null
		echo -e $VERDE"OK"$NORMAL
	else
		echo " EL proceso ha muerto antes por si mismo."
	fi
done

echo -e $BLANCO"> Matando semaphores de apache..."$NORMAL
ipcs -s | grep apache | perl -e 'while (<STDIN>) { @a=split(/\s+/); print `ipcrm sem $a[1]`}'

echo -e $BLANCO"> "$VERDE"Ok"$NORMAL

