#!/bin/bash

ZONASDIR="/service/tinydns/root/dominios-hostalip"

echo -e "> Comprobando si hay cambios en hostalip...\c"
ssh hostalip.qaop.com ls /usr/local/admin/dns/cambios.timestamp &> /dev/null
if [ $? -eq 0 ]
then
	echo -e "HAY cambios: \c"
	ssh hostalip.qaop.com cat /usr/local/admin/dns/cambios.timestamp
else
	echo "SIN cambios."
	exit 0
fi

# Borrar el timestamp:
echo -e "> Borrando timestamp...\c"
ssh hostalip.qaop.com rm -f /usr/local/admin/dns/cambios.timestamp
echo "OK"

# Borrar zonas actuales:
echo -e "> Borrando zonas actuales...\c"
rm -f $ZONASDIR/* &> /dev/null
echo "OK"

# Copiar zonas de host-a-lip:
echo "> Copiando zonas:"
scp hostalip.qaop.com:/usr/local/admin/dns/* $ZONASDIR/

# Remake:
echo "> Lanzando remake:"
rcdjbdns remake

