#!/bin/bash

# Busca directorios demasiado gordos por el disco.
# (GPLv3) jorge@jorgefuertes.com

if [ $# -lt 2 ]
then
	echo "BuscaGordos - ©2009 Jorge Fuertes (jorge@jorgefuertes.com)"
	echo "Este software se cede bajo contrato GPLv3."
	echo 
	echo "Busca directorios gordos por el disco."
	echo
	echo "Utilización:"
	echo "  $0 <ruta inicial> <tamaño limite>"
	echo "El tamaño límite debe especificarse en (M)egas o (G)igas."
	echo "Ejemplo: $0 /var 100M"
	echo
	exit 1
fi

echo "Buscando directorios más gordos de $2 en $1..."
echo

echo $2 | egrep ".*G$" &> /dev/null
if [ $? -eq 0 ]
then
	MLIMIT=$(expr $(echo $2|cut -f1 -d"G") \* 1024)
else
	MLIMIT=$(echo $2|cut -f1 -d"M")
fi
KLIMIT=$(expr $MLIMIT \* 1024)

for i in $(find $1 -maxdepth 1 -type d) 
do
	SIZE=$(du -xs \
		--exclude="/sys" \
       		--exclude="/proc" \
		--exclude="/dev" \
		$i 2> /dev/null | tr -s "\t" "|" | cut -f1 -d"|")
	if [ $SIZE -gt $KLIMIT ]
	then
		MEGAS=$(expr $SIZE / 1024)
		if [ $MEGAS -lt 1024 ]
		then
			TOTAL="${MEGAS} Mb"
		else
			TOTAL=$(expr $MEGAS / 1024)" Gb"
		fi
		while [ $(expr length "$TOTAL") -lt 8 ]
		do
			TOTAL="${TOTAL}."
		done
		
		echo "${TOTAL}: $i"
	fi
done

echo
echo "<EOF>";
