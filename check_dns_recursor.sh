#!/bin/bash

NS=$(cat /etc/resolv.conf |egrep "^nameserver"|head -n1|cut -f2 -d" ")
echo -n "DNS recursor $NS..."

while [ 1 ]
do
	if [ -f /usr/bin/host ]
	then
		#host -t A -W 5 gmail.com $NS &> /dev/null
		# El parámetro W no funciona en etch
		host -t A gmail.com $NS &> /dev/null
		NIVEL=$?
		if [ $NIVEL -eq 0 ]
		then
			echo "OK"
		else
			echo "FALLO"
			echo "Fallo consultando DNS a $NS" > /dev/stderr
		fi
		exit $NIVEL
	else
		echo -n "instalando dnsutils..."
		aptitude -y install dnsutils &> /dev/null
	fi
done
