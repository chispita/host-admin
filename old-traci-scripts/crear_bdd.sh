#!/bin/bash

# Crea una BDD y un usuario con permisos de MySQL:

source /usr/local/admin/colores.inc

echo -e $CYAN"\n+ ALTA DE BDD MySQL:\n"$NORMAL

if [ -z "$1" ]
then
	echo -e "    - "$VERDE"Usuario:"$BLANCO" \c"
	read USU
else
        echo -e "    - "$VERDE"Usuario: "$BLANCO$1
        USU=$1
fi

if [ -z "$USU" ]
then
        echo -e $ROJO"\n¡Usuario vacío!$NORMAL\n"
        exit 1
fi

if [ -z "$2" ]
then
	echo -e "    - "$VERDE"Password:"$BLANCO" \c"
	read PASS
else
        echo -e "    - "$VERDE"Password: "$BLANCO$1
        PASS=$2
fi

if [ -z "$PASS" ]
then
        echo -e $ROJO"\n¡Password vacío!$NORMAL\n"
        exit 1
fi

# BDD:
echo -e "    - Base de datos......: $BLANCO$USU$NORMAL"
echo "CREATE DATABASE $USU;" | mysql

# Usuario MySQL:
echo -e "    - Usuario MySQL......: $BLANCO$USU$NORMAL//$BLANCO$PASS$NORMAL"
echo "INSERT INTO mysql.user (Host,User,Password) VALUES ('localhost', '$USU', PASSWORD('$PASS'));" | mysql
echo "INSERT INTO mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Grant_priv,References_priv, \
        Index_priv,Alter_priv,Create_tmp_table_priv,Lock_tables_priv) \
        VALUES ('localhost', '$USU', '$USU', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'Y', 'Y');" | mysql
echo "FLUSH PRIVILEGES;" | mysql

