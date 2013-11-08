#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "ALTA DE FTP"

if [ -z "$1" ]
then
	pregunta "Dominio FQDN" DOM
else
	DOM=$1
fi

USU=$(echo $DOM|tr '.-' '__')

if [ -z "$2" ]
then
	pregunta "Clave" PASS
else
	PASS=$2
fi

if [ -z "$3" ]
then
	pregunta "Cuota de disco (en MB)" CUOTA "100"
else
	CUOTA=$3
fi

echo
informa "Usuario.: $USU"
informa "Clave...: $PASS"
informa "Cuota...: $CUOTA Mb"

sino "Confirma el alta de FTP con esos datos?"
if [[ $? -ne 0 ]]
then
	informa "ABORTADO"
	finalizado 1
fi

sql "Creando usuario FTP" \
	"INSERT INTO sistemas.ftpusers (nombre,login,uid,gid,pass,dir,QuotaSize,ULBandwidth,DLBandwidth) \
	VALUES ('$DOM','$USU','$WEB_UID','$WEB_GID','$PASS','/web/$DOM','$CUOTA','100','100');"

finalizado
