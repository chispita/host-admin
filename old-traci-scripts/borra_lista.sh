#!/bin/bash

# Borra una lista de correo.
# queru@queru.org - Abril 2005.

# Constantes:
MAILMANDIR="/usr/local/mailman"

# Colores:
source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"+------------------------+"
echo             "| Borrar lista de correo |"
echo -e          "+------------------------+\n"$NORMAL

echo -e "- "$VERDE"¿Lista? ("$AMARILLO"Sin @dominio.com"$VERDE"):"$NORMAL" \c" 
if [ $# -lt 1 ]
then
        read LISTA
else
        LISTA=$1
        echo $LISTA
fi

if [ -z $LISTA ]
then
	echo -e $ROJO"\n¡Especifique una lista!\n"$NORMAL
	exit 1
fi

if [ -d $MAILMANDIR/lists/$LISTA ]
then
	# Borrar:
	echo "> Borrando $LISTA..."
	$MAILMANDIR/bin/rmlist -a $MAILMANDIR/lists/$LISTA
	echo "> OK"
else
	echo -e $ROJO"\n¡No existe ninguna lista con ese nombre!\n"$NORMAL
fi
