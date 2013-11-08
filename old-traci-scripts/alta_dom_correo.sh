#!/bin/bash

# Da de alta un dominio de correo.
# Comprueba que no exista.

source /usr/local/admin/colores.inc

echo -e $CYAN"\n+ ALTA DOMINIO DE CORREO:\n"$NORMAL

if [ -z "$1" ]
then
	echo -e "    - "$VERDE"Dominio:"$BLANCO" \c"
	read DOM
else
        echo -e "    - "$VERDE"Dominio: "$BLANCO$1
        DOM=$1
fi

if [ -z "$DOM" ]
then
	echo -e $ROJO"\n¡Dominio vacío!$NORMAL\n"
	exit 1
fi

if [ -z "$2" ]
then
	echo -e $BLANCO"    - "$VERDE"Password:"$BLANCO" \c"
	read PASS
else
        echo -e "    - "$VERDE"Password: "$BLANCO$2
        PASS=$2
fi
	
if [ -z "$PASS" ]
then
	echo -e $ROJO"\n¡Debe especificar una contraseña!$NORMAL\n"
	exit 1
fi

EXISTE=$(echo "SELECT domain FROM cqtraci.domain WHERE domain='$DOM';" | mysql -NB)
if [ -n "$EXISTE" ]
then
	echo -e $ROJO"\n!El dominio ya existe!\n"$NORMAL
else
	echo -e $BLANCO"    > "$NORMAL"Insertando en la base de datos..."

	# Eliminado el catchall:
	# INSERT INTO alias (address, goto, domain, created, modified, active) \
	#	VALUES ('@$DOM','postmaster@$DOM','$DOM',NOW(),NOW(),1); \
	echo	"USE cqtraci; \
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
				VALUES ('postmaster@$DOM', '$DOM', NOW() , '1'); " \
			| mysql
fi

echo "Buzón activado." | mail -s "Activación de buzón." postmaster@$DOM

echo -e $AZUL"\n> Finalizado.$NORMAL\n"
