#!/bin/bash

# Description: Copy to remote host a file
#     Creator: Carlos Val Gascon
#        Date: JAN/17/2013
#########################################################333


EXPECTED_ARGS=2

if [ $# -lt $EXPECTED_ARGS ]
then
       	echo "CopiaRemoto- ©2013 Carlos Val (carlos.val.gascon@gmail.com)"
        echo
	echo "Copia un archivo a los hosts remotos"
	echo
	echo "Utilización:"
        echo "  $0 <archivo a copiar> <directorio destino>"
	echo "Ejemplo: $0 test.txt /tmp"
	echo
        exit 1
fi



hosts=( 'srv2' 'srv3' 'srv4' 'node4')
#hosts=( 'srv2' 'srv3' 'srv4' 'node3' 'node4')
domain_name=".ibercivis.es"
user="root"

E_FILESOURCE=64
E_BADARGS=65

for i in "${hosts[@]}"
do
    printf "Copiando archivo ${1} a ${i}${domain_name}...\n"

     scp ${1} $user@${i}${domain_name}:${2}
done


