#!/bin/bash

source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"+ ALTA TOTAL DE DOMINIO:\n"$NORMAL

if [ -z "$1" ]
then
	echo -e "    - "$VERDE"Dominio:"$BLANCO" \c"
	read DOM
else
	echo -e "    - "$VERDE"Dominio: "$BLANCO$1
	DOM=$1
fi

if [ -e /web/domains/$DOM ]
then
	echo " "
	echo -e $ROJO"      ********************************************"
	echo -e	     "      * WARNING: DIRECTORIO DE DOMINIO YA EXISTE *"
	echo -e $ROJO"      *"$BLANCO" (No será borrado, pero el usuario podría "$ROJO"*"
	echo -e	     "      *"$BLANCO" ser creado dos veces.)                   "$ROJO"*"
	echo -e	     "      ********************************************\n"$NORMAL
fi	

if [ -z "$2" ]
then
	echo -e "    - "$VERDE"Password:"$BLANCO" \c"
	read PASS
else
	echo -e "    - "$VERDE"Password: "$BLANCO$2
	PASS=$2
fi

if [ -z "$3" ]
then
	echo -e "    - "$VERDE"Mb cuota de disco (50):"$BLANCO" \c"
	read CUOTA
	if [ -z $CUOTA ]
	then
		CUOTA=50
	fi
else
	echo -e "    - "$VERDE"Cuota de disco: "$BLANCO$3" Mb."
	CUOTA=$3
fi

echo -e $CYAN"\n¿Confirma el alta del dominio con esos datos? (S/n):"$BLANCO" \c"
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

# ALTA
# Home:
FTPUID=$(echo "SELECT MAX(uid)+1 FROM cqtraci.ftp;" | mysql | tail -n 1)
echo -e $NORMAL"\n    - Creando home.......: "$BLANCO"/web/domains/$DOM"$NORMAL
mkdir -p /web/domains/$DOM/htdocs
echo -e $NORMAL"\n    - Copiando index.....:"$BLANCO"/web/default/index.php$DOM"$NORMAL
cp /web/default/index.php /web/domains/$DOM/htdocs
echo -e "    - Ajustando permisos.: "$BLANCO"UID #"$FTPUID$NORMAL
chown -R $FTPUID:$FTPUID /web/domains/$DOM

# FTP:
USU=$(echo $DOM|tr ".-" "__")
echo -e "    - Usuario FTP........: $BLANCO$USU$NORMAL//$BLANCO$PASS$NORMAL"
echo -e "    - Siguiente UID......: $BLANCO$FTPUID$NORMAL"
echo "INSERT INTO cqtraci.ftp (name,uid,gid,pwd,home,quota,domain) \
        VALUES ('$USU','$FTPUID','$FTPUID','$PASS','/web/domains/$DOM','$CUOTA','$DOM');" | mysql

# BDD:
/usr/local/admin/alta_bdd.sh $USU $USU $PASS

# Correo:
echo -e "    - Dominio de correo..: $BLANCO@$DOM"$NORMAL
/usr/local/admin/alta_dom_correo.sh $DOM $PASS

# DNS:
echo -e "    - Zona DNS:\n"
rcdjbdns wdom $DOM 194.143.194.244
echo " "

echo -e "    - Generando informe..: \c"
echo "ToDo"
echo -e "    - Avisos correo......: \c"
echo "ToDo"
echo -e "\n"$AZUL"Finalizado..."$NORMAL"\n"

/usr/local/admin/datos_dom.sh $DOM

