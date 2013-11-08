#!/bin/bash

LAST=1

for NUM in $(echo "SELECT NUMERO FROM hispalinux_secre.socio ORDER BY NUMERO;"|mysql -N --disable-pager)
do
	echo "Comprobando $LAST"
	echo -e "\e[2A"
	if [ $LAST -ne $NUM ]
	then
		until [ $LAST -eq $NUM ]
		do
			echo "$LAST: Libre                          "
			let LAST++
		done
	       	FECHA=$(echo "SELECT FECHAALTA FROM hispalinux_secre.socio WHERE NUMERO=$LAST;" \
			| mysql -N --disable-pager)
		echo "Fecha siguiente: $FECHA"
	fi
	let LAST++
done

