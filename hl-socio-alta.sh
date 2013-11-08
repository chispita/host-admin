#!/bin/bash

# Config:
APP_PATH="/usr/local/admin"
source $APP_PATH/include/colores.inc.sh
source $APP_PATH/include/funciones.inc.sh

clear
titulo "Alta de socio de Hispalinux"

# Por defecto:
NUMERO="Auto"
PAIS="España"
NACIONALIDAD="Española"

while [ 1 ]
do
	informa "Datos del nuevo socio (Ctrl-C: Salir):"

	pregunta    "Número"        NUMERO    "$NUMERO"
	preguntaobg "Nombre 1"      NOMBRE1   "$NOMBRE1"
	pregunta    "Nombre 2"      NOMBRE2   "$NOMBRE2"
	preguntaobg "Apellido 1"    APELLIDO1 "$APELLIDO1"
	pregunta    "Apellido 2"    APELLIDO2 "$APELLIDO2"
	preguntaobg "Dirección"     DIRECCION "$DIRECCION"
	preguntaobg "Localidad"     LOCALIDAD "$LOCALIDAD"
	preguntaobg "Provincia"     PROVINCIA "$PROVINCIA"
	preguntaobg "CP"            CP        "$CP"
	pregunta    "País"          PAIS      "$PAIS"
	preguntaobg "DNI"           DNI       "$DNI"
	preguntaobg "EMAIL 1"       EMAIL1    "$EMAIL1"
	pregunta    "EMAIL 2"       EMAIL2    "$EMAIL2"
	
	if [ -z "$EMAILHL" ]
	then
		EMAILHL=$(echo "${NOMBRE1}${NOMBRE2}.${APELLIDO1}@hispalinux.es"|tr "A-Z" "a-z"|tr " " "-")
		preguntaobg "EMAIL HL" EMAILHL "$EMAILHL"
	fi
	
	pregunta    "Teléfono 1"    TELEFONO1    "$TELEFONO1"
	pregunta    "Teléfono 2"    TELEFONO2    "$TELEFONO2"
	pregunta    "Nacionalidad"  NACIONALIDAD "$NACIONALIDAD"
	
	sino "Insertar en la BDD"
	if [ $? -eq 0 ]
	then
		if [ "$NUMERO" == "Auto" ]
		then
			NUMERO=""
		fi
		QUERY="INSERT \
			INTO hispalinux_secre.socio (NUMERO, NOMBRE1, NOMBRE2, APELLIDO1, APELLIDO2, DIRECCION, LOCALIDAD, \
				PROVINCIA, CP, PAIS, DNI, EMAIL1, EMAIL2, EMAIL_HISPALINUX, FECHAALTA, TELEFONO1, \
				TELEFONO2, NACIONALIDAD) \
			VALUES ('$NUMERO', '$NOMBRE1', '$NOMBRE2' , '$APELLIDO1', '$APELLIDO2', '$DIRECCION', '$LOCALIDAD', '$PROVINCIA', \
				'$CP', '$PAIS', '$DNI', '$EMAIL1', '$EMAIL2', '$EMAILHL', 'NOW()', '$TELEFONO1', '$TELEFONO1', '$NACIONALIDAD');"
		echo "---[QUERY INSERT]---"
		echo $QUERY
		echo "--------------------"
		sql "Insertando registro" $QUERY
		ok $?
		query "Registro insertado" "SELECT NUMERO, EMAIL_HISPALINUX FROM hispalinux_secre.socio WHERE EMAIL_HISPALINUX = '$EMAILHL';"
	else
		informa "Cancelado"
	fi
	
	echo "-------------"
	sino "Dar más altas"
	if [ $? -ne 0 ]
	then
		break
	fi
done

finalizado
