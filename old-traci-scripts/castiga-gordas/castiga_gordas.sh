#!/bin/bash

DIRACTUAL=$(pwd)

# Desactiva una web:
function desactiva_web()
{
	cd /web/domains
	tar -cjpf /web/desactivados_gorda/$1.tar.bz2 $1
	rm -Rf $1
	ln -s desactivado $1
}

function desactiva_email
{
	echo -n "."
}

function desactiva_ftp
{
	echo -n "."
}

function redirige_dns
{
	echo -n "."
}

# Bucle de castigo:
for dom in $(cat dominios_viaapia.txt)
do
	echo -n "> Desactivando $dom..."
	#echo -n "web..."
	#desactiva_web $dom
	echo -n "email..."
	desactiva_email $dom
	echo -n "ftp..."
	desactiva_ftp $dom
	echo -n "dns..."
	redirige_dns $dom
	echo "Ok."
done

cd $DIRACTUAL

echo "> Proceso finalizado."
echo " "

