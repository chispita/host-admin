#!/bin/bash

APP_PATH="/usr/local/admin"
source $APP_PATH/include/funciones.inc.sh

titulo "CAMBIO DE ALIAS (SISTEMA) DE HISPALINUX"

pregunta "Dirección de @hispalinux.es" HL

query "Buscando" "SELECT ID, MAIL, FORWARD, COMMENT FROM hispalinux_secre.aliases WHERE MAIL like '${HL}%';"
if [ $? -ne 0 ]
then
	informa "Email no encontrado."
	exit 1
fi

pregunta "ID" ID

pregunta "Nuevo forward" FWD

sql "Actualizando" "UPDATE hispalinux_secre.aliases SET FORWARD='${FWD}' WHERE aliases.ID=${ID} LIMIT 1;"

query "Comprobando" "SELECT ID, MAIL, FORWARD FROM hispalinux_secre.aliases WHERE ID=${ID};"
	
sino "¿Resincronizar?"
if [ $? -eq 0 ]
then
	/usr/local/admin/sincro_hlx_secre.sh
fi

finalizado
