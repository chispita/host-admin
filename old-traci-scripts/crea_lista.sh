#/bin/bash
# -------------------------
# Script para crear listas de correo
# Queru: si quieres pasarlo a php, alla tu.
#  |-> No pero remozarlo un poco y hacer que funcione si.
# Va a ir para sudo.
#  |-> No creo que hayas sudao mucho para esto no.
# -------------------------

# Colores:
source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"Crear una lista de correo"
echo -e      "=====================================\n"$NORMAL

echo -e "    - "$VERDE"¿Lista? (lista@dominio.com):"$NORMAL" \c" 
if [ $# -lt 1 ]
then
        read LISTA
else
        LISTA=$1
        echo $LISTA
fi

echo -e "    - "$VERDE"¿Administrador de la lista? (email):"$NORMAL" \c" 
if [ $# -lt 2 ]
then
        read ADMIN
else
        ADMIN=$2
        echo $ADMIN
fi

echo -e "    - "$VERDE"¿Contraseña?:"$NORMAL" \c" 
if [ $# -lt 3 ]
then
        read PWD
else
        PWD=$3
        echo $PWD
fi

MAILMANDIR="/usr/local/mailman"

# Comprueba el nombre
NOMBRE=$(echo $LISTA | cut -f1 -d@)
if [ -d "$MAILMANDIR/lists/$NOMBRE" ] ; then
	echo -e $ROJO"\n¡La lista $NOMBRE ya existe!\n"$NORMAL
	exit 1
fi

echo -e "> Creando lista...\c"
su - mailman -c "$MAILMANDIR/bin/newlist -l es -q $LISTA $ADMIN $PWD > /tmp/crealista" &> /dev/null
su - mailman -c "/usr/local/mailman/bin/check_perms -f" &> /dev/null
echo "OK"

# Regenera los alias:
echo -e "> Regenerando los alias...\c"
/usr/local/mailman/bin/genaliases
echo "OK"
