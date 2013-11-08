#!/bin/bash

# Da de alta un dominio de correo.
# Comprueba que no exista.

source /usr/local/admin/include/hosting-conf.inc.sh

titulo "ALTA DOMINIO DE CORREO"

if [ -z "$1" ]
then
	preguntaobg "Dominio" DOM
else
        DOM=$1
fi

if [ -z "$2" ]
then
	preguntaobg "Clave" CLEARPASS
else
        CLEARPASS=$2
fi

PASS=$($APP_PATH/md5crypt $CLEARPASS)

echo	
informa "Dominio..: $DOM"
informa "Clave....: $CLEARPASS"
informa "md5crypt.: $PASS"

if [ -z "$1" ]
then
	sino "Confirma el alta del con esos datos?"
	if [[ $? -ne 0 ]]
	then
		informa "ABORTADO"
		finalizado 1
	fi
fi

EXISTE=$(echo "SELECT domain FROM sistemas_mail.domain WHERE domain='$DOM';" | mysql -NB)
if [ -n "$EXISTE" ]
then
	errorgrave "El dominio ya existe!!!"
else
	sql "Insertando en la base de datos" \
		"USE sistemas_mail; \
			INSERT INTO alias (address, goto, domain, created, modified, active) 
				VALUES ('abuse@$DOM','postmaster@$DOM','$DOM',NOW(),NOW(),1); \
			INSERT INTO alias (address, goto, domain, created, modified, active) \
				VALUES ('hostmaster@$DOM','postmaster@$DOM','$DOM',NOW(),NOW(),1); \
			INSERT INTO alias (address, goto, domain, created, modified, active) \
				VALUES ('webmaster@$DOM','postmaster@$DOM','$DOM',NOW(),NOW(),1); \
			INSERT INTO alias (address, goto, domain, created, modified, active) \
				VALUES ('postmaster@$DOM','postmaster@$DOM','$DOM',NOW(),NOW(),1); \
			INSERT INTO domain (domain, description, aliases, mailboxes, maxquota, created, modified, active) \
				VALUES ('$DOM','Dominio de correo de $DOM',100,100,100,NOW(),NOW(),1); \
			INSERT INTO mailbox (username, password, name, maildir, quota, domain, created, modified, active) \
				VALUES ('postmaster@$DOM','$PASS','postmaster','$DOM/postmaster/',104857600,'$DOM',NOW(),NOW(),1); \
			INSERT INTO admin (username, password, created, modified, active) 
				VALUES ('postmaster@$DOM', '$PASS', NOW() , NOW() , '1');
			INSERT INTO domain_admins (username, domain, created, active)
				VALUES ('postmaster@$DOM', '$DOM', NOW() , '1');"
fi

haciendo "Activando buzon"
echo "Buzón activado. Bienvenido." | mail -s "Activación de buzón." postmaster@$DOM
ok $?

finalizado
