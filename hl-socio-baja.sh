#!/bin/bash

# Config:
APP_PATH="/usr/local/admin"
source $APP_PATH/include/colores.inc.sh
source $APP_PATH/include/funciones.inc.sh

clear
titulo "Baja de socio de Hispalinux"

preguntaobg "Numero de socio" NUM

query "Buscando socio $NUM" "SELECT numero, nombre1, nombre2, apellido1, apellido2, dni FROM hispalinux_secre.socio WHERE numero = $NUM;"


finalizado
