#!/bin/bash

source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"+ BAJA TOTAL DE DOMINIO:\n"$NORMAL

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
        echo -e $AMARILLO"\n*** ABORTADO ***\n"$NORMAL
	exit 1
fi

echo -e $CYAN"\n¿Confirma el baja el dominio $DOM? (S/n):"$BLANCO" \c"
read -n1 SINO
if [ -z "$SINO" ]
then
	SINO="s"
fi
if [ "$SINO" == "S" ]
then
        SINO="s"
fi
if [ "$SINO" != "s" ]
then
        echo -e $AMARILLO"\n*** ABORTADO ***\n"$NORMAL
        exit 1
fi

echo " "

# DNS:
if [ -e /service/tinydns/root/dominios-qaop/$DOM ]
then
	echo "    - Borrando dominio DNS..."
	rm /service/tinydns/root/dominios-qaop/$DOM
	echo "    - Remake zonas DNS..."
	rcdjbdns remake &> /dev/null
else
	echo -e $ROJO"    - No existe zona DNS."$NORMAL
fi

# Directorio WEB:
if [ -e /web/domains/$DOM ]
then
        echo "    - Realizando copia de seguridad dominio..."
	mkdir -p /web/bajas
	tar -cjpf /web/bajas/$DOM-$(date +"%s").tar.bz2 /web/domains/$DOM &> /dev/null
	echo "    - Borrando directorio..."
	rm -Rf /web/domains/$DOM
else
	echo -e $ROJO"    - No existe directorio web."$NORMAL
fi
										
# Usuarios FTP:
echo "    - Borrando usuarios FTP..."
echo "DELETE FROM cqtraci.ftp WHERE domain='$DOM';" | mysql

# Usuarios BDD:
USU=$(echo $DOM|tr ".-" "__")
echo "    - Borrando usuario de la BDD..."
echo "DELETE FROM mysql.user WHERE User='$USU';" | mysql
echo "DELETE FROM mysql.db WHERE User='$USU';" | mysql

# Base de datos:
echo "    - Borrando base de datos..."
echo "DROP DATABASE $USU;" | mysql

# Correo:
echo "    - Baja de correo..."
/usr/local/admin/baja_dom_correo.sh $DOM

echo -e "\n"$AZUL"Finalizado."$NORMAL"\n"

