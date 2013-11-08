#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "BAJA TOTAL DE DOMINIO"

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

sino "Confirma ${ROJO}BAJA${NORMAL} del dominio ${AMARILLO}${DOM}${NORMAL}?"
if [[ $? -ne 0 ]]
then
	informa "ABORTADO"
	finalizado 1
fi

# baja:
# Web:
$APP_PATH/baja_web.sh -y $DOM

# BDD:
$APP_PATH/baja_bdd.sh -y $DOM

# CORREO:
$APP_PATH/baja_correo.sh -y $DOM

# DNS:
$APP_PATH/baja_dns.sh -y $DOM

# FTP:
$APP_PATH/baja_ftp.sh -y $DOM

finalizado
