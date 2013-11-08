#!/bin/bash

# Listado de listas de correo.
# queru@queru.org - Abril 2005.

# Constantes:
MAILMANDIR="/usr/local/mailman"

# Colores:
source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"+--------------------------+"
echo             "| Listas de correo creadas |"
echo -e          "+--------------------------+\n"$NORMAL

for i in $(ls -c1 $MAILMANDIR/lists)
do
	echo -e "> "$BLANCO$i$NORMAL"."
done

echo -e "\n<EOF>"
