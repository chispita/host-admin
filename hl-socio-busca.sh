#!/bin/bash

APP_PATH="/usr/local/admin"
source $APP_PATH/include/funciones.inc.sh

titulo "Busca socio de Hispalinux"

echo
echo "Buscar por:"
echo "-----------------------"
echo "1 Número de socio"
echo "2 Nombre y apellidos"
echo "3 eMail"
echo "4 DNI"
echo "X Salir"
echo

preguntaobg "Opción" OPC "x"

case $OPC in
	x)
		finalizado 0
		;;
	1)
		echo
		informa "Búsqueda por número de socio."
		preguntaobg "Número" NUM
		query "Buscando socio $NUM" \
			"SELECT numero, CONCAT(email1, '->', email_hispalinux), nombre1, nombre2, apellido1, apellido2 \
			FROM hispalinux_secre.socio WHERE numero = '$NUM';"
		;;
	2)
		echo
		informa "Búsqueda por nombre y apellidos."
		pregunta "Nombre" NOMBRE
		pregunta "Apellido 1" APE1
		pregunta "Apellido 2" APE2
		query "Buscando a $NOMBRE $APE1 $APE2" \
			"SELECT numero, email_hispalinux, nombre1, nombre2, apellido1, apellido2 \
			FROM hispalinux_secre.socio WHERE nombre1 LIKE '$NOMBRE%' \
			AND apellido1 LIKE '$APE1%' \
			AND apellido2 LIKE '$APE2%';"
		;;
	3)
		echo
		informa "Búsqueda por número de email."
		preguntaobg "eMail privado" EMAIL
		query "Buscando $EMAIL" \
			"SELECT numero, email_hispalinux, nombre1, nombre2, apellido1, apellido2 \
			FROM hispalinux_secre.socio WHERE email1 = '$EMAIL';"
		;;
	4)
		echo
		informa "Búsqueda por DNI."
		preguntaobg "DNI" NUM
		query "Buscando DNI $NUM" \
			"SELECT numero, CONCAT(email1, '->', email_hispalinux), nombre1, nombre2, apellido1, apellido2 \
			FROM hispalinux_secre.socio WHERE dni LIKE '$NUM%';"
		;;
esac

finalizado 0
