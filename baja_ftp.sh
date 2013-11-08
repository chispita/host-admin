#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "Baja de FTP"

if [[ "$1" == "-y" ]]
then
	SIATODO="si"
	DOM=$2
else
	DOM=$1
fi

if [ -z "$DOM" ]
then
	aviso "Uso: $0 [-y] <fqdn>"
	errorgrave "Falta parámetro."
else
        informa "Dominio: $DOM"
fi

USU=$(echo "$DOM"|tr '.-' '__'|sed "s/á/a/g;s/é/e/g;s/í/i/g;s/ó/o/g;s/ú/u/g;s/ñ/n/g")

sql "Borrando usuario FTP" \
	"DELETE FROM sistemas.ftpusers WHERE login='$USU' LIMIT 1;"

finalizado 0
