#/bin/bash
# -------------------------
# Script para suscribir a listas de correo
# -------------------------

# Colores:
source /usr/local/admin/colores.inc

if [ $# -lt 1 ]
then
		echo -e "    - "$VERDE"¿Lista? (lista@dominio.com):"$NORMAL" \c" 
        read LISTA
else
        LISTA=$1
fi

if [ $# -lt 2 ]
then
		echo -e "    - "$VERDE"¿Suscriptor? (email):"$NORMAL" \c" 
        read SUS
else
        SUS=$2
fi

MAILMANDIR="/usr/local/mailman"
PID=$$
# Comprueba el nombre
NOMBRE=$(echo $LISTA | cut -f1 -d@)
if [ ! -d "$MAILMANDIR/lists/$NOMBRE" ] ; then
	echo -e "\n"$ROJO"La lista $NOMBRE NO existe.\n"$NORMAL
	exit 1
fi
echo $SUS > /tmp/add2list.$PID
su - mailman -c "$MAILMANDIR/bin/add_members -w y -a y -r /tmp/add2list.$PID $NOMBRE"
echo -e "> Suscrito $AMARILLO$SUS$BLANCO -> $CYAN$LISTA"$NORMAL
rm /tmp/add2list.$PID
