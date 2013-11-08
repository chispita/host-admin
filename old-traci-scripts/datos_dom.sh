#!/bin/bash

# Colores:
source /usr/local/admin/colores.inc

if [ $# -lt 1 ]
then
	echo -e "- "$VERDE"¿Dominio?:"$NORMAL" \c" 
	read DOM
else
	DOM=$1
fi

USU=$(echo $DOM|tr ".-" "__")
PASS=$(echo "select pwd from cqtraci.ftp where name='"$USU"';"|mysql -N)
CUOTA=$(echo "SELECT quota FROM cqtraci.ftp WHERE name='"$USU"' AND domain='"$DOM"';" | mysql -B -s)
POSTMASTERPASS=$(echo "select password from cqtraci.admin where username='postmaster@"$DOM"';"|mysql -N)
USUDB=$(echo "select user from mysql.db where db='"$USU"' limit 1;"|mysql -N)

echo " "
echo "+-----------------------------------+"
echo "| I N F O R M E  D E  D O M I N I O |"
echo "+-----------------------------------+"
echo " - Dominio......: $DOM"
echo " - Web..........: http://$DOM"
echo " "
#echo " - Gestión......: http://$DOM/_GESTION"
#echo " - Usuario......: $USU"
#echo " - Passwd.......: $PASS"
#echo " "
echo " - Disco........: /web/domains/$DOM"
echo " - Cuota........: $CUOTA Mb"
echo " "
echo " - FTP..........: ftp://$DOM"
echo " - Usuario......: $USU"
echo " - Passwd.......: $PASS"
echo " "
echo " - MySQL........: localhost"
echo " - Usuario......: $USUDB"
echo " - Passwd.......: $PASS"
echo " - MySQL-Admin..: http://$DOM/_MYADMIN"
echo " "
echo " - Correo.......: correo.$DOM (smtp/pop3)"
echo " - WebMail......: http://$DOM/_CORREO"
echo " - Admin........: http://$DOM/_ADMINCORREO"
echo " - Postmaster...: postmaster@$DOM"
echo " - Passwd.......: $POSTMASTERPASS"
echo " "
#echo " - Estadísticas.: http://$DOM/_STATS"
#echo " "

