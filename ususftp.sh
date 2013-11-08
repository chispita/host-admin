#!/bin/bash

# Lista todos los usuarios de ftp:
source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"+ LISTADO DE USUARIOS DE FTP:\n"$NORMAL
echo "select login,uid,pass,dir,QuotaSize from sistemas.ftpusers;" | mysql -t
echo -e "\n"$AZUL"<EOF>\n"$NORMAL

