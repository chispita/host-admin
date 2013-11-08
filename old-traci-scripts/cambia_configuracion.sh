#!/bin/bash
###########################################################
# copyleft by calocen
# script para sustituir los ficheros de configuracion
# de gentoo por las nuevas versiones
# esta escrito en modo "didactico"
# (hay faltas de ortografia por el juego de caracteres)
###########################################################
for i in $(find /etc -iname '._cfg*')
do
	# cortamos el path eliminando desde el ultimo slash
	a=${i%/*}
	# ahora cortamos a la derecha del anterior
	b=${i#$a/}
	# separamos el nombre del fichero original
	c=${b:10}
	# y la serie
	d=${b:5:4}

	# mostramos el resultado
	echo -e "i:$i\n\ta:$a\n\tb:$b\n\tc:$c\n\td:$d"

	# ahora a operar
	# cambiamos el fichero original(c) por una copia de seguridad
	# con la serie (d)
	mv -v $a/$c $a/$c.$d.gnt
	# y reemplazamos el original por la nueva version
	mv -v $i $a/$c
done
