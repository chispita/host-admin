#!/bin/bash

APP_PATH="/usr/local/admin"
ADDUTIL="/usr/local/admin/add2file-ifnotexists.sh"
FILTROS="mx1.spamfiltro.es, mx2.spamfiltro.es"
RELAY_DOMAINS="/etc/postfix/relay_domains"
RELAY_RECIPIENTS="/etc/postfix/relay_recipients"
TRANSPORT="/etc/postfix/transport"

source $APP_PATH/include/funciones.inc.sh

titulo "ALTA EN FILTRO ANTIESPAM"

preguntaobg "Nombre de dominio" DOM $1
preguntaobg "SMTP de destino" SMTP "correo.conectahosting.es"

echo
informa "${DOM} --> ${SMTP}"
echo
sino "¿Confirma alta?"
echo
if [ $? -eq 0 ]
then
	for filtro in $(echo $FILTROS | tr -d " " | tr "," "\n")
	do
		haciendo "${filtro}-> relay_domains"
		ssh root@$filtro "${ADDUTIL} '${DOM} OK' ${RELAY_DOMAINS}"
		ok $?

		haciendo "${filtro}-> relay_recipients"
		ssh root@$filtro "${ADDUTIL} '@${DOM} OK' ${RELAY_RECIPIENTS}"
		ok $?

		haciendo "${filtro}-> transport"
		ssh root@$filtro "${ADDUTIL} '${DOM} smtp:${SMTP}' ${TRANSPORT}"
		ok $?
	
		haciendo "${filtro}-> Recompilando .dbs"
		ssh root@$filtro "cd /etc/postfix; postmap ${TRANSPORT}; postmap ${RELAY_DOMAINS}; postmap ${RELAY_RECIPIENTS}"
		ok $?
		echo
	done
else
	aviso "Cancelado"
fi

finalizado 0
