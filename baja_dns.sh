#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "Baja de zona DNS"

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

informa "Baja en veid $DNS_VEID"

vzctl exec $DNS_VEID $DNS_CMD -y rmdom $DOM|grep "+|***"
vzctl exec $DNS_VEID $DNS_CMD -y remake|grep "+|***"

finalizado
