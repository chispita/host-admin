#!/bin/bash

# Busca directorios demasiado gordos por el disco.
# (Copyleft) queru@zaragozawireless.net

# Megas a partir de los cuales un directorio es
# considerado "gordo":
GORDO=10
FICHERO="/tmp/dufile.tmp"

echo "Ficheros mayores de $GORDO megas:"
echo "---------------------------------"

for i in `du -Sm|tr -t "[:blank:]" "|"|tr "[:blank:]" "_"`
do
        TAM=$(echo $i|cut -f1 -d"|")
        FIC=$(echo $i|cut -f2 -d"|")
        if [ $TAM -gt $GORDO ]
        then
                echo "GORDO: $FIC: $TAM Mb."
        fi
done

