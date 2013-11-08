#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "Baja servidor web"

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

preguntaobg "Servidor web? (rapido/inside)" SVR
if [ $SVR == "rapido" ]
then
        WEB_DIR=$RAPIDO_WEB_DIR
else
        WEB_DIR=$INSIDE_WEB_DIR
fi

if [ -e $WEB_DIR/$DOM ]
then
	informa "Directorio web: $WEB_DIR/$DOM"
else
	aviso "No existe: $WEB_DIR/$DOM"
	errorgrave "El directorio web no existe."
fi	

haciendo "Copia de seguridad"
FICBK=$WEB_BKDIR/$DOM-$(date +"%d%m%Y_%H%M%S").tgz
tar czf $FICBK $WEB_DIR/$DOM
ok $?
informa "Copia en $FICBK"

haciendo "Ajustando permisos"
chmod 600 $FICBK
ok $?

haciendo "Borrando $WEB_DIR/$DOM"
rm -Rf $WEB_DIR/$DOM
ok $?

finalizado 0
