#!/bin/bash

source /usr/local/admin/include/hosting-conf.inc.sh

if [ -z "$1" ]
then
	preguntaobg "Dominio FQDN" DOM
else
	DOM=$1
fi

USU=$(echo $DOM|tr '.-' '__'|sed "s/á/a/g;s/é/e/g;s/í/i/g;s/ó/o/g;s/ú/u/g;s/ñ/n/g")
BDD="${BDD_PRE}${USU}"
PASS=$(echo "select pass from sistemas.ftpusers where login='"$USU"';"|mysql -N)
CUOTA=$(echo "SELECT QuotaSize FROM sistemas.ftpusers WHERE login='"$USU"' AND nombre='"$DOM"';" | mysql -B -s)
USUDB=$(echo "select user from mysql.db where db='"$BDD"' limit 1;"|mysql -N)

echo
echo "+-----------------------------------+"
echo "| I N F O R M E  D E  D O M I N I O |"
echo "+-----------------------------------+"
echo " - Dominio......: $DOM"
echo " - Web..........: http://$DOM"
echo " - Web..........: http://www.$DOM"
echo
#echo " - Gestión......: http://$DOM/_GESTION"
#echo " - Usuario......: $USU"
#echo " - Passwd.......: $PASS"
#echo " "
echo " - Disco........: /web/$DOM"
echo " - Cuota........: $CUOTA Mb"
echo
echo " - FTP..........: ftp://$DOM"
echo " - Usuario......: $USU"
echo " - Passwd.......: $PASS"
echo
echo " - MySQL host...: $BDD_HOST"
echo " - Base datos...: $BDD"
echo " - Usuario......: $BDD"
echo " - Passwd.......: $PASS"
echo " - MySQL-Admin..: http://$DOM/_MYSQL"
echo
echo " - Correo.......: correo.$DOM (smtp/pop3)"
echo " - WebMail......: http://$DOM/_WEBMAIL"
echo " - Admin........: http://$DOM/_ADMINCORREO"
echo " - Postmaster...: postmaster@$DOM"
echo " - Passwd.......: $PASS"
echo " "
#echo " - Estadísticas.: http://$DOM/_STATS"
#echo " "
