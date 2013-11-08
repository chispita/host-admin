#!/bin/bash

COPIAR="add2file-ifnotexists.sh, \
	profile.local.sh, \
	check_dns_recursor.sh, \
	buscagordos.sh, \
	cronic"

source /usr/local/admin/include/funciones.inc.sh

titulo "Preparando scripts containers"

for i in $(ls -C1 /vz/private/)
do
	DEST="/vz/private/$i/usr/local/admin"
	echo "+ $i:"
	haciendo "Creando dir admin"
	mkdir -p $DEST
	ok $?
	for fic in $(echo $COPIAR|tr -d "[:space:]"|tr "," "\n")
	do
		haciendo "Copiando $fic"
		cp /usr/local/admin/$fic $DEST/.
		ok $?
	done
	haciendo "Limpiando cache apt"
	vzctl exec $i aptitude clean &> /dev/null
	ok $?
done

finalizado
