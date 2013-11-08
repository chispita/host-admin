# Administración del cluster de DNS.

source /usr/local/admin/include/funciones.inc.sh

ESTE=$(hostname)

if [ "$ESTE" == "briana" ]
then
	DNSCT="103"
else
	DNSCT="102"
fi

vzctl exec $DNSCT /usr/local/admin/rctinydns.sh $*

