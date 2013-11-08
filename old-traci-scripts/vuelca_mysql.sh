#!/bin/sh

# Colores:
source /usr/local/admin/colores.inc
# Timestamp:
MARCATEMP=$(date +"%d%h%Y_%H%M%S")

# Parámetros:
if [ $# -lt 1 ]
then
		echo -e "    - "$VERDE"¿Base de datos a volcar?:"$NORMAL" \c" 
        read BDD
else
        BDD=$1
fi

# Salida:
OUT="BackUp_MySQL_"$BDD"_"$MARCATEMP".sql"

if [ $# -lt 2 ]
then
		echo -e "    - "$VERDE"¿Fichero de salida? ("$OUT"):"$NORMAL" \c" 
        read SALIDA
else
        SALIDA=$2
fi

if [ "$SALIDA" == "" ]
then
	SALIDA=$OUT
fi

echo "Volcando backup a $OUT..."

mysqldump \
	$BDD \
	-hlocalhost \
	--all \
	--opt \
	--allow-keywords \
	--hex-blob \
	--master-data \
	--quote-names \
	--max_allowed_packet=16M \
	--result-file=$SALIDA

echo "Comprimiendo..."

gzip $SALIDA

echo "Finalizado."
