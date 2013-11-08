#!/bin/bash

# Da de baja un dominio de correo.
# Comprueba que exista.

source /usr/local/admin/colores.inc

echo -e $CYAN"\n+ BAJA DOMINIO DE CORREO:\n"$NORMAL

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

EXISTE=$(echo "SELECT domain FROM cqtraci.domain WHERE domain='$DOM';" | mysql -NB)
if [ -z "$EXISTE" ]
then
	echo -e $ROJO"\n!El dominio no existe!\n"$NORMAL
	# exit 1
fi

echo -e $BLANCO"    > "$NORMAL"Borrando de la base de datos..."

echo	"USE cqtraci; \
		DELETE FROM alias WHERE domain='$DOM'; \
		DELETE FROM domain_admins WHERE domain='$DOM'; \
		DELETE FROM admin WHERE username LIKE '%@$DOM'; \
		DELETE FROM domain WHERE domain='$DOM' LIMIT 1; \
		DELETE FROM mailbox WHERE domain='$DOM';" \
		| mysql
		
echo -e $AZUL"\n> Finalizado.$NORMAL\n"
