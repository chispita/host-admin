#!/bin/bash

# Lista todos los usuarios de ftp:
source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"+ LISTADO DE USUARIOS DE FTP:\n"$NORMAL
echo "select name,uid,pwd,home,quota,chroot from cqtraci.ftp;" | mysql -t
echo -e "\n"$AZUL"<EOF>\n"$NORMAL

