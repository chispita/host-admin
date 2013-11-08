#!/bin/bash

if $(ps -A|grep r0nin &> /dev/null)
then
	(
		echo "¡Se ha detectado una instancia de r0nin!"
		echo "# ps -ef|grep r0nin"
		ps -ef|grep r0nin
		echo "# netstat -lnp|grep 0.0.0.0:80"
		netstat -lnp|grep 0.0.0.0:80
		echo "# locate r0nin"
		locate r0nin
		echo " "
		echo "# killall -9 r0nin"
		killall -9 r0nin
		echo "# levanta.sh apache2"
		levanta.sh apache2
	) | mail -s "¡Detectado r0nin en traci!" soporte@conectahosting.com
fi

if $(ps -ef|egrep "^apache"|egrep -v "/usr/sbin/apache2|defunct")
then
	(
		echo "¡Hay cosas corriendo bajo el usuario apache!:"
		ps -ef|egrep "^apache"|egrep -v "/usr/sbin/apache2|defunct"
                echo "# netstat -lnp|grep 0.0.0.0:80"
                netstat -lnp|grep 0.0.0.0:80
	) | mail -s "¡Detectadas cosas extrañas en traci!" soporte@conectahosting.com
fi

