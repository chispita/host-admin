#!/bin/bash

APP_PATH="/usr/local/admin"

source $APP_PATH/include/funciones.inc.sh
source $APP_PATH/include/colores.inc.sh

titulo "CAMBIO DE ALIAS DE HISPALINUX"

pregunta "Dirección de @hispalinux.es" HL

query "Buscando" "SELECT NUMERO, NOMBRE1, APELLIDO1, APELLIDO2, EMAIL1 FROM hispalinux_secre.socio WHERE EMAIL_HISPALINUX like '${HL}%';"
if [ $? -ne 0 ]
then
	informa "Email no encontrado."
	exit 1
fi

pregunta "Númerio de socio" SOCIO

pregunta "Nuevo email" EMAIL

query "Actualizando" "UPDATE hispalinux_secre.socio SET EMAIL1='${EMAIL}' WHERE socio.NUMERO=${SOCIO} LIMIT 1;"

query "Comprobando" "SELECT NUMERO, NOMBRE1, APELLIDO1, APELLIDO2, EMAIL1 FROM hispalinux_secre.socio WHERE NUMERO=${SOCIO};"
	
sino "¿Resincronizar?"
if [ $? -eq 0 ]
then
	/usr/local/admin/sincro_hlx_secre.sh
fi

finalizado
