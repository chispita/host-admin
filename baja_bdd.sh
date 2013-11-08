#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "BAJA DE BDD Y USUARIO"

if [[ "$1" == "-y" ]]
then
	SIATODO="si"
	DOM=$2
else
	DOM=$1
fi

if [ -z "$DOM" ]
then
	aviso "Uso: baja_bdd.sh [-y] <fqdn>"
	errorgrave "Falta parámetro."
else
	informa "FQDN....: $DOM"
fi

BDD=$(echo "$DOM"|tr '.-' '__'|sed "s/á/a/g;s/é/e/g;s/í/i/g;s/ó/o/g;s/ú/u/g;s/ñ/n/g")
BDD="hs_$BDD"
USU=$BDD

informa "BDD.....: $BDD"
informa "USUARIO.: $USU"
sino "¿Confirma la baja de la BDD y USUARIO con esos datos?"
if [[ $? -ne 0 ]]
then
	informa "ABORTADO"
	finalizado 1
fi

sql "Borrando usuario" "DELETE FROM mysql.user WHERE User='$USU';"
sql "Borrando permisos" "DELETE FROM mysql.db WHERE User='$USU';"
sql "Borrando base de datos" "DROP DATABASE $BDD;"
sql "Recargando privilegios" "FLUSH PRIVILEGES;"

finalizado 0

