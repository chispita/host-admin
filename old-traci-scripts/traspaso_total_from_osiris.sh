#!/bin/bash

# ------------------------------------------
# Pasa un dominio web desde osiris a traci.
# Copia tanto los ficheros como la base de
# datos y el usuario ftp.
# ------------------------------------------
# Queru y Calocén 2005 por culo te la hinco.
# ------------------------------------------

# Caminos:
DOMINIOS="/web/domain"
APP="/usr/local/admin"

# Colores:
source /usr/local/admin/colores.inc

echo " "
echo -e $CYAN"COPIAR DOMINIO DE OSIRIS:"
echo -e "========================="$NORMAL
echo " "
echo -e $VERDE"Dominio (sin 'www.'): "$NORMAL"\c"
if [ $# -lt 1 ]
then
	read DOM
else
        DOM=$1
	echo $DOM
fi
echo $DOM|grep -E "www+\.[-a-zA-Z0-9]+\.[-a-zA-Z0-9]+*" &> /dev/null
if [ $? -eq 0 ]
then
        echo -e $ROJO"¡QUE NO TECLEE 'www.', COÑO!"$NORMAL
	exit 1
fi
echo $DOM|grep -E "[-a-zA-Z0-9]+\.[-a-zA-Z0-9]+\.[-a-zA-Z0-9]+*" &> /dev/null
if [ $? -eq 0 ]
then
	# Es un subdominio. No ponemos las www:
	DOM_HTTP=$DOM
else
        DOM_HTTP=www.$DOM
fi

echo " "
echo "------------------------------------------------------------------"
echo -e $AMARILLO"Dominio: $DOM_HTTP"$NORMAL
echo "------------------------------------------------------------------"
echo " "

echo "+ Datos de ftp desde osiris:"
PWD=$(echo "SELECT pwd FROM cqdata.ftp WHERE domain='$DOM_HTTP';" | \
	mysql --batch --host="osiris.qaop.com" --user="cqconsulta" --password="cq.6912" |tail -n 1)
if [ -z "$PWD" ]
then
	echo "*** ERROR: No existe en la base de datos. ***"
	exit 1
fi

CUOTA=$(echo "SELECT quota FROM cqdata.ftp WHERE domain='$DOM_HTTP';" | \
	mysql --batch --host="osiris.qaop.com" --user="cqconsulta" --password="cq.6912" |tail -n 1)
echo "  - Password.: "$PWD
echo "  - Cuota....: "$CUOTA

echo "+ Creando usuario en BDD cqtraci.ftp..."
FTPUID=$(echo "SELECT MAX(uid)+1 FROM cqtraci.ftp;" | mysql | tail -n 1)
echo "  - Siguiente UID.: "$FTPUID
NOMBRE=$(echo $DOM|tr ".-" "__")
echo "  - Login.........: "$NOMBRE
echo "INSERT INTO cqtraci.ftp (name,uid,gid,pwd,home,quota,domain) \
	VALUES ('$NOMBRE','$FTPUID','$FTPUID','$PWD','/web/domains/$DOM','$CUOTA','$DOM');" | mysql

echo "+ Copiando htdocs desde osiris..."
mkdir -p /web/domains/$DOM/htdocs
scp -rq root@osiris.qaop.com:/web/domain/$DOM_HTTP/. /web/domains/$DOM/htdocs/.
echo "  - Ajustando permisos..."
chown -R $FTPUID:$FTPUID /web/domains/$DOM

echo "+ Creando y copiando BDD:"
OSIRIS_BDD=$(echo $DOM_HTTP|tr "." "_")
echo "SHOW DATABASES;" | mysql --user="toor" --password="toorsql" --host="osiris.qaop.com"|grep $OSIRIS_BDD &> /dev/null
if [ $? -ne 0 ]
then
	echo -e $ROJO"  - No existe BDD en osiris."$NORMAL
else
	echo "  - Exportando BDD..."
	echo -e "CREATE DATABASE $NOMBRE;\nUSE $NOMBRE;\n\n" > /tmp/$NOMBRE-export.sql
	mysqldump --host="osiris.qaop.com" --user="toor" --password="toorsql" $OSIRIS_BDD >> /tmp/$NOMBRE-export.sql
	echo "  - Importando BDD -> $NOMBRE..."
	cat /tmp/$NOMBRE-export.sql | mysql
	rm /tmp/$NOMBRE-export.sql
	echo "  - Permisos de la BDD..."
	echo "INSERT INTO mysql.user (Host,User,Password) VALUES ('localhost', '$NOMBRE', PASSWORD('$PWD'));" | mysql
	echo "INSERT INTO mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Grant_priv,References_priv, \
		Index_priv,Alter_priv,Create_tmp_table_priv,Lock_tables_priv) \
		VALUES ('localhost', '$NOMBRE', '$NOMBRE', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'Y', 'Y');" | mysql
	echo "FLUSH PRIVILEGES;" | mysql
fi

echo "+ Creando dominio de correo:"
/usr/local/admin/alta_dom_correo.sh $DOM $PWD

echo "+ Traspasando buzones desde osiris:"
/usr/local/admin/traspaso_buzones_from_osiris.sh $DOM

/usr/local/admin/rcdjbdns wdom $DOM

echo -e $CYAN"\n¿Desea dar el dominio de baja en osiris? (s/N):"$BLANCO" \c"
read -n1 SINO

if [ -z "$SINO" ]
then
	SINO="n"
fi
if [ "$SINO" == "S" ]
then
        SINO="s"
fi

if [ "$SINO" == "s" ]
then
	ssh root@osiris.qaop.com /usr/local/admin/cqdaemon/baja_total.sh $DOM
fi

echo -e "\n"$VERDE"Finalizado."$NORMAL"\n"$CYAN"Recuerde ajustar el DNS."$NORMAL"\n"

