#!/bin/bash

# quota_ftp.sh
# Ajusta la cuota FTP de un dominio.

# Colores:
source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"Ajustar la cuota de FTP de un dominio"
echo -e      "=====================================\n"$NORMAL

echo -e "    - "$VERDE"¿Dominio?:"$NORMAL" \c" 
if [ $# -lt 1 ]
then
        read DOM
else
        DOM=$1
        echo $DOM
fi

TRUSU=$(echo $DOM|tr "." "_")
echo -e "    - "$VERDE"¿Usuario? ("$TRUSU"):"$NORMAL" \c" 
if [ $# -lt 2 ]
then
	read USU
else
	USU=$2
	echo $USU
fi

if [ -z "$USU" ]
then
	USU=$TRUSU
fi

ACTUAL=`echo "SELECT quota FROM cqtraci.ftp WHERE name='"$USU"' AND domain='"$DOM"';" | mysql -B -s`
if [ "$ACTUAL" == "" ]
then
	echo -e $ROJO"¡ERROR! Dominio/Usuario no encontrado."$NORMAL
	exit
fi
echo -e "    > "$AMARILLO"Actualmente la cuota es de "$BLANCO$ACTUAL$AMARILLO" Mb"$NORMAL
	
echo -e "    - "$VERDE"Cuota FTP (En Mb) (50): "$NORMAL"\c"
if [ $# -lt 3 ]
then
	read QUOTA
else
        QUOTA=$3
        echo $QUOTA
fi

if [ -z $QUOTA ]
then
        QUOTA=50
fi

echo -e "    > "$VERDE"Ajustando la cuota de '"$DOM"' a "$QUOTA" Megabytes."$NORMAL
echo "UPDATE cqtraci.ftp SET quota="$QUOTA" WHERE name='"$USU"' AND domain='"$DOM"' LIMIT 1;" | mysql
echo -e "    > "$AMARILLO"OK."$NORMAL
echo -e "\n"$AZUL"Finalizado."$NORMAL"\n"
