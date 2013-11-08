#!/bin/bash

source /usr/local/admin/include/colores.inc.sh

if [ "$1" == "install" ]
then
	echo "+--------------------------------------------------+"
	echo -e "| ${ROJO}ESTA USTED EN UN HOST${NORMAL}                            |"
	echo "| ¿Está seguro de que quiere instalar cosas en él? |"
	echo "|                                                  |"
	echo "| Instale sólo cosas imprescindibles, y el resto   |"
	echo "| en máquinas virtuales.                           |"
	echo "+--------------------------------------------------+"
	echo " "

	echo -e "¿Continuar con la ejecución? (s/N): \c"

	read -n1 SN
	echo " "
	if [ "$SN" != "s" ]
	then
		echo -e "${VERDE}Cancelado${NORMAL}."
		exit 0
	fi
fi

/usr/bin/aptitude $@
