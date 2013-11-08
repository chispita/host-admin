#!/bin/bash

# comandos.sh
# Ayuda sobre los comandos adicionales del sistema.
# queru@qaop.com

# Colores:
NORMAL="\e[0m"
BOLD="\e[1m"
INVERSO="\e[30;47m"
ROJO="$BOLD\e[31m"
VERDE="$BOLD\e[32m"
MARRON="$BOLD\e[33m"
AZUL="$BOLD\e[34m"
MAGENTA="$BOLD\e[35m"
CYAN="$BOLD\e[36m"
BLANCO="$BOLD\e[37m"
FORTUNECOLOR="$MARRON"
AMARILLO="$MARRON"

echo -e $AZUL"o-oo-oo-oo-oo-oo-oo-oo-oo-oo-oo-oo-o"
echo -e	     "| "$CYAN"COMANDOS ADICIONALES DEL SISTEMA"$AZUL" |"
echo -e      "o-oo-oo-oo-oo-oo-oo-oo-oo-oo-oo-oo-o"$NORMAL"\n"

echo -e     $ROJO"> AUXILIARES:"$NORMAL
echo -e $AMARILLO"    comandos.sh"$AZUL"________________________________________"$CYAN"Esta ayuda."
echo -e    $VERDE"    cdadmin"$AZUL"____________________________________________"$CYAN"cd al directorio de administración."
echo -e    $VERDE"    la"$AZUL"_________________________________________________"$CYAN"ls ampliado."
echo -e     $ROJO"> DNS:"$NORMAL
echo -e    $VERDE"    rcdjbdns"$AZUL"___________________________________________"$CYAN"Control de servidor de DNS."
echo -e     $ROJO"> DISCO:"$NORMAL
echo -e    $VERDE"    montabk.sh/desmontabk.sh"$AZUL"___________________________"$CYAN"Monta y desmonta el disco de backups."
echo -e     $ROJO"> FTP:"$NORMAL
echo -e    $VERDE"    cuota_ftp.sh [<usuario> <dominio> <quota_en_Mb>]"$AZUL"___"$CYAN"Ajusta la cuota de FTP de un usuario."
echo -e    $VERDE"    crea_usu_ftp.sh"$AZUL"____________________________________"$CYAN"Crea un usuario independiente de FTP."
echo -e    $VERDE"    borra_usu_ftp.sh"$AZUL"___________________________________"$CYAN"Borra un usuario de FTP."
echo -e    $VERDE"    listaftp.sh"$AZUL"________________________________________"$CYAN"Lista todos los usuarios de FTP."
echo -e     $ROJO"> HOSTING:"$NORMAL
echo -e    $VERDE"    alta_total.sh [dom] [pass] [quota]"$AZUL"_________________"$CYAN"Dar de alta un dominio (Web/Correo/FTP/DNS)."
echo -e    $VERDE"    baja_total.sh [dom]"$AZUL"________________________________"$CYAN"Dar de baja totalmente un dominio."
echo -e    $VERDE"    verpassdom.sh [dom]"$AZUL"________________________________"$CYAN"Ver la password de un dominio."
echo -e    $VERDE"    cambiapassdom.sh [dom]"$AZUL"_____________________________"$CYAN"Ver la password de un dominio."
echo -e    $VERDE"    traspaso_total_from_osiris.sh"$AZUL"______________________"$CYAN"Traspasar TODO un dominio desde osiris."
echo -e    $VERDE"  * existedom.sh [dom]"$AZUL"_________________________________"$CYAN"Mira sin un dominio existe en el sistema."
echo -e     $ROJO"> CORREO:"$NORMAL
echo -e    $VERDE"    alta_dom_correo.sh [dom] [passwd]"$AZUL"__________________"$CYAN"Añadir un dominio de correo."
echo -e    $VERDE"  * ver_dominios_correo.sh"$AZUL"_____________________________"$CYAN"Listado de los dominios de correo."
echo -e    $VERDE"    crea_lista.sh [dom]"$AZUL"________________________________"$CYAN"Crea una lista de correo."
echo -e    $VERDE"    borra_lista.sh [dom]"$AZUL"_______________________________"$CYAN"Borra una lista de correo."
echo -e    $VERDE"    lista_listas.sh [dom]"$AZUL"______________________________"$CYAN"Listado de listas de correo."
echo -e " "
echo -e $MARRON"Los comandos precedidos de un asterisco todavía están siendo pasados de osiris a traci."$NORMAL
echo " "
