#!/bin/bash

DESTINO=/web/domains/viernes.org/htdocs/zivis_stats.txt
TEMPORAL=/tmp/zivi.tmp
FECHA=$(date +"%H:%M:%S@%d-%m-%Y")

links -receive-timeout 15 -unrestartable-receive-timeout 15 -dump http://zivis.bifi.unizar.es/ranking/index.php?view=3 > $TEMPORAL

if [ $? -lt 1 ]
then
	cat $TEMPORAL | grep -A 5 "^\ *1\ "|cut -c4- > $DESTINO
	echo " " >> $DESTINO

	# Puntos del primero y del segundo:
	PRIMERO=$(cat $DESTINO|grep "^1"|cut -c58-)
	SEGUNDO=$(cat $DESTINO|grep "^2"|cut -c58-)
	# Ventaja primero sobre el segundo:
	DIFERENCIA=$(echo $PRIMERO - $SEGUNDO|bc|cut -f1 -d".")
	# Ventaja anteriores 30min.:
	DIFANTERIOR=$(cat /web/domains/viernes.org/htdocs/zivis_dif.txt)
	echo $DIFERENCIA > /web/domains/viernes.org/htdocs/zivis_dif.txt
	# Diferencial ultimos 30min.:
	DIFERENCIAL=$(echo $DIFERENCIA - $DIFANTERIOR|bc|cut -f1 -d".")
	# Tendencia:
	if [ $DIFERENCIA -gt $DIFANTERIOR ]
	then
		TENDENCIA="Al alza ($DIFERENCIAL)"
	else
		TENDENCIA="A la baja ($DIFERENCIAL)"
	fi

	echo "<strong>Ventaja primero......: $DIFERENCIA puntos</strong>." >> $DESTINO
	echo "Tendencia ventaja....: $TENDENCIA" >> $DESTINO
	echo "Última actualización.: "$FECHA >> $DESTINO
	echo "(Actualiza cada 30min.)" >> $DESTINO

	ESPARTANOS="/web/domains/viernes.org/htdocs/zivis_espartanos.txt"
	links -dump http://zivis.bifi.unizar.es/ranking/full.php|grep "softwarelibre"|grep -v "155.210"|cut -c11-|cut -f1 -d" "|sort -u -f > $ESPARTANOS
	NUMESPARTANOS=$(cat $ESPARTANOS|wc -l)
	echo "<br /><br />" >> $ESPARTANOS
	echo "<strong>Solamente $NUMESPARTANOS linuxeros repartiendo ciclos de CPU como panes</strong>." >> $ESPARTANOS
else
	echo "ERROR: No se pudo contactar con el servidor de Zivis." > $DESTINO
fi
