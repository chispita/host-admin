#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "Alta de zona DNS"

if [ -z "$1" ]
then
	preguntaobg "Dominio FQDN" DOM
else
	DOM=$1
	informa "Dominio: $DOM"
fi

informa "Alta en veid $DNS_VEID"

vzctl exec $DNS_VEID $DNS_CMD wdom $DOM
vzctl exec $DNS_VEID $DNS_CMD remake

finalizado
