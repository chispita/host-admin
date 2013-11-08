#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "ALTA TOTAL DE DOMINIO"

if [ -z "$1" ]
then
	preguntaobg "Dominio FQDN" DOM
else
	DOM=$1
	informa "Dominio: $DOM"
fi

if [ -z "$2" ]
then
	preguntaobg "Clave:" PASS
else
	PASS=$2
	informa "Clave: $PASS"
fi

if [ -z "$3" ]
then
	preguntaobg "Mb cuota de disco:" CUOTA
else
	CUOTA=$3
	informa "Cuota de disco: $CUOTA"
fi

sino "¿Confirma el alta del dominio con esos datos?"
if [[ $? -ne 0 ]]
then
	informa "ABORTADO"
	finalizado 1
fi

# ALTA:
# Web:
$APP_PATH/alta_web.sh $DOM

# BDD:
$APP_PATH/alta_bdd.sh $DOM $PASS

# CORREO:
$APP_PATH/alta_correo.sh $DOM $PASS

# DNS:
$APP_PATH/alta_dns.sh $DOM

# FTP:
$APP_PATH/alta_ftp.sh $DOM $PASS $CUOTA

# Datos del dominio:
$APP_PATH/datos_dom.sh $DOM

finalizado
