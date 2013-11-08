#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "ALTA DE BDD Y USUARIO"
informa "Host BDD: $BDD_HOST"

if [ -z "$1" ]
then
	preguntaobg "Nombre BDD" BDD
else
	BDD=$1
fi

if [ -z "$2" ]
then
	preguntaobg "Prefijo BDD" PRE $BDD_PRE
fi

BDD=$(echo $BDD|tr '.-' '__'|sed "s/á/a/g;s/é/e/g;s/í/i/g;s/ó/o/g;s/ú/u/g;s/ñ/n/g")
BDD=$BDD_PRE$BDD
USU=$BDD

if [ -z "$2" ]
then
	pregunta "Clave" PASS
else
	PASS=$2
fi

echo
informa "Nombre BDD.: $BDD"
informa "Usuario....: $USU"
informa "Clave......: $PASS"

if [ -z "$1" ]
then
	sino "¿Confirma el alta del con esos datos?"
	if [[ $? -ne 0 ]]
	then
		informa "ABORTADO"
		finalizado 1
	fi
fi

# BDD:
sql "Creando base de datos $BDD" "CREATE DATABASE ${BDD} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
# Usuario MySQL:
sql "Usuario MySQL $USUL//$PASS" "INSERT INTO mysql.user (Host,User,Password) VALUES ('%', '$USU', PASSWORD('$PASS'));"
sql "Privilegios" "INSERT INTO mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv, \
	Drop_priv,Grant_priv,References_priv,Index_priv,Alter_priv,Create_tmp_table_priv,Lock_tables_priv) \
	VALUES ('%', '$BDD', '$USU', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'Y', 'Y');"
sql "Recargando privilegios" "FLUSH PRIVILEGES;"

finalizado
