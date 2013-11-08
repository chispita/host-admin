#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "Alta servidor web"

if [ -z "$1" ]
then
	preguntaobg "Dominio FQDN" DOM
else
	DOM=$1
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
	aviso "Directorio web ya existe."
	aviso "$WEB_DIR/$DOM"
	aviso "No será borrado."
fi	

haciendo "Creando directorio web $WEB_DIR/$DOM"
mkdir -p $WEB_DIR/$DOM/htdocs
ok $?

haciendo "Instalando página 'en construcción'"
cp -a $APP_PATH/include/mantenimiento $WEB_DIR/$DOM/htdocs/.
ok $?
haciendo "Enlazando index"
DIRACT=$(pwd)
cd $WEB_DIR/$DOM/htdocs
ln -s mantenimiento/index.php .
ok $?
cd $DIRACT

haciendo "Ajustando permisos"
chown -R $WEB_UID:$WEB_GID $WEB_DIR/$DOM
ok $?

finalizado
