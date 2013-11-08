#!/bin/bash

# Da de baja un dominio de correo.
# Comprueba que exista.

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "BAJA DOMINIO DE CORREO"

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

EXISTE=$(echo "SELECT domain FROM sistemas_mail.domain WHERE domain='$DOM';" | mysql -NB)
if [ -n "$EXISTE" ]
then
	sino "¿Confirma borrado de domino de correo de $DOM?"
	if [ $? -eq 0 ]
	then
		sql "Borrando de la base de datos" \
			"USE sistemas_mail; \
				DELETE FROM alias WHERE domain='$DOM'; \
				DELETE FROM domain_admins WHERE domain='$DOM'; \
				DELETE FROM admin WHERE username LIKE '%@$DOM'; \
				DELETE FROM domain WHERE domain='$DOM' LIMIT 1; \
				DELETE FROM mailbox WHERE domain='$DOM';"
		haciendo "Comprimiendo directorio de correo"
		mkdir -p $BACKUP_DIR/mail
		tar czf $BACKUP_DIR/mail/$DOM.tgz $MAIL_DOMS/$DOM &> /dev/null
		ok $?
		haciendo "Borrando directorio de correo"
		rm -Rf $MAIL_DOMS/$DOM
		ok $?
	else
		aviso "Abortado"
	fi
else
	aviso "¡El dominio no existe!"
fi

finalizado
