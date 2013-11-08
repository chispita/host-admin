#!/bin/bash

# Alta de un buzón de correo:

source /usr/local/admin/colores.inc

echo -e $CYAN"\n+ ALTA BUZON DE CORREO:\n"$NORMAL

if [ -z "$1" ]
then
	echo -e "    - "$VERDE"Buzón:"$BLANCO" \c"
	read BUZDOM
else
        echo -e "    - "$VERDE"Buzón: "$BLANCO$1
        BUZDOM=$1
fi

if [ -z "$BUZDOM" ]
then
	echo -e $ROJO"\n¡Dominio vacío!$NORMAL\n"
	exit 1
fi

BUZON=$(echo $BUZDOM|cut -f1 -d"@")
DOM=$(echo $BUZDOM|cut -f2 -d"@")

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
    EXISTE=$(echo "SELECT username FROM cqtraci.mailbox WHERE username='$BUZDOM';" | mysql -NB)
    if [ -n "$EXISTE" ]
    then
	echo -e $ROJO"\n!Este buzón ya existe!\n"$NORMAL
	exit 1
    else
	echo -e $BLANCO"    > "$NORMAL"Insertando en la base de datos..."
	echo    "USE cqtraci; \
	         INSERT INTO alias (address, goto, domain, created, modified, active) \
		   VALUES ('$BUZON@$DOM','$BUZON@$DOM','$DOM',NOW(),NOW(),1); \
	         INSERT INTO mailbox (username, password, name, maildir, quota, domain, created, modified, active) \
		   VALUES ('$BUZON@$DOM','$PASS','$BUZON','$DOM/$BUZON/',104857600,'$DOM',NOW(),NOW(),1);" | mysql
		
	echo "Buzón activado." | mail -s "Activación de buzón." $BUZON@$DOM
    fi
else
	echo -e $ROJO"\n!El dominio "$DOM" no existe!\n"$NORMAL
	exit 1
fi

echo -e $AZUL"\n> Finalizado.$NORMAL\n"
