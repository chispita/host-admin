#!/bin/bash

source /usr/local/admin/colores.inc

echo -e "\n"$CYAN"+ ALTA DE USUARIO DE BDD:"$NORMAL

if [ -z "$1" ]
then
	echo -e "    - "$VERDE"Nombre BDD.:"$BLANCO" \c"
	read BDD
else
	echo -e "    - "$VERDE"Nombre BDD.: "$BLANCO$1
	BDD=$1
fi

if [ -z "$2" ]
then
	echo -e "    - "$VERDE"Usuario....:"$BLANCO" \c"
	read USU
else
	echo -e "    - "$VERDE"Usuario....: "$BLANCO$2
	USU=$2
fi

if [ -z "$3" ]
then
	echo -e "    - "$VERDE"Clave......:"$BLANCO" \c"
	read PAS
else
	echo -e "    - "$VERDE"Clave......: "$BLANCO$3
	PAS=$3
fi

echo -e $CYAN"\n¿Confirma el alta del con esos datos? (S/n):"$BLANCO" \c"
read -n1 SINO

echo " "

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

echo -e "\n    - Base de datos......: $BLANCO$BDD$NORMAL"

# Usuario MySQL:
echo -e "    - Usuario MySQL......: $BLANCO$USU$NORMAL//$BLANCO$PAS$NORMAL"
echo "INSERT INTO mysql.user (Host,User,Password) VALUES ('localhost', '$USU', PASSWORD('$PAS'));" | mysql
if [ $? -ne 0 ]
then
	echo -e $ROJO"\n¡ERROR creando usuario $BLANCO$USU$ROJO!"$NORMAL
	exit 1
fi
echo "INSERT INTO mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Grant_priv,References_priv, \
	Index_priv,Alter_priv,Create_tmp_table_priv,Lock_tables_priv) \
	VALUES ('localhost', '$BDD', '$USU', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'Y', 'Y');" | mysql
if [ $? -ne 0 ]
then
	echo -e $ROJO"\n¡ERROR insertando privilegios!"$NORMAL
	exit 1
fi
echo "FLUSH PRIVILEGES;" | mysql
