#!/bin/bash

# Genera las configuraciones de awstats para todos los dominios de la máquina, actualiza sus estadísticas
# y genera las páginas estáticas.
# queru@queru.org - Sep 2005

source /usr/local/admin/colores.inc

APP="/usr/local/admin/estadisticas"
CONF="/etc/awstats"
LOG="/var/log/apache2/access_log"
AWS="nice -n19 /web/default/_STATS/cgi-bin/awstats.pl"
DOMS="/web/default/_STATS/dominios"
DIRTMP="$APP/tmp"
FTMP="$DIRTMP/access_log.tmp"
VERBOSE="si"

function decir {
	if [ "$VERBOSE" == "si" ]
	then
		echo -e $1
	fi
}

# Anotar inicio en el log:
echo $(date +"[%d-%m-%Y@%H:%M:%S]")" Inicio de actualización." >> /var/log/admin/awstats.log

# Crear temporal:
mkdir -p $DIRTMP &> /dev/null

# Comprobar que no esté rulando ya:
# Que no haya un log pendiente:
if [ "$1" != "resume" ]
then
	if [ -e $FTMP ]
	then
		echo -e $ROJO"\nHay un log temporal pendiente:"$NORMAL
		ls -laiFh $FTMP
		echo -e $AMARILLO"Si desea reprocesarlo, utilice el parámetro "$VERDE"resume"$AMARILLO".\n"$NORMAL
		echo $(date +"[%d-%m-%Y@%H:%M:%S]")" SALIDA: Log temporal pendiente." >> /var/log/admin/awstats.log
		exit 1
	fi
	# Mover el log de apache y truncarlo a cero.
	# Si no se ha especificado 'resume':
	decir $VERDE"> Detener apache y capturar el log:"$NORMAL
	/etc/init.d/apache2 stop &> /dev/null
	killall -9 apache2 &> /dev/null
	sleep 2
	mv $LOG $FTMP
	cat /dev/null > $LOG
	chown apache:apache $LOG
	chmod 664 $LOG
	sleep 2
	decir $VERDE"> Rearranque de apache..."$NORMAL
	/etc/init.d/apache2 start &> /dev/null
fi

rm -f $CONF/*.conf &> /dev/null
for i in $(ls -C1 /web/domains| egrep -v "^default$|^194\.143\.194\.244")
do
	USU=$(echo $i | tr "." "_")
	OUT=$DOMS"/"$USU
	decir $AMARILLO"\n> Estadísticas de $i...\n"$NORMAL
	echo $(date +"[%d-%m-%Y@%H:%M:%S]")" Actualizando $i." >> /var/log/admin/awstats.log
	# Generar configuración:
	cat $APP/data/awstats.conf | sed -e s/__DOMINIO__/$i/g -e s/__USUARIO__/$USU/g > $CONF/awstats.$i.conf
	# Actualizar databases:
	$AWS -config=$i -update
	# Generar las páginas
	$AWS -config=$i -output -lang=es -staticlinks > $OUT/awstats.$i.html
	$AWS -config=$i -output=alldomains -lang=es -staticlinks > $OUT/awstats.$i.alldomains.html
	$AWS -config=$i -output=allhosts -lang=es -staticlinks > $OUT/awstats.$i.allhosts.html
	$AWS -config=$i -output=lasthosts -lang=es -staticlinks > $OUT/awstats.$i.lasthosts.html
	$AWS -config=$i -output=unknownip -lang=es -staticlinks > $OUT/awstats.$i.unknownip.html
	$AWS -config=$i -output=alllogins -lang=es -staticlinks > $OUT/awstats.$i.alllogins.html
	$AWS -config=$i -output=lastlogins -lang=es -staticlinks > $OUT/awstats.$i.lastlogins.html
	$AWS -config=$i -output=allrobots -lang=es -staticlinks > $OUT/awstats.$i.allrobots.html
	$AWS -config=$i -output=lastrobots -lang=es -staticlinks > $OUT/awstats.$i.lastrobots.html
	$AWS -config=$i -output=urldetail -lang=es -staticlinks > $OUT/awstats.$i.urldetail.html
	$AWS -config=$i -output=urlentry -lang=es -staticlinks > $OUT/awstats.$i.urlentry.html
	$AWS -config=$i -output=urlexit -lang=es -staticlinks > $OUT/awstats.$i.urlexit.html
	$AWS -config=$i -output=browserdetail -lang=es -staticlinks > $OUT/awstats.$i.browserdetail.html
	$AWS -config=$i -output=osdetail -lang=es -staticlinks > $OUT/awstats.$i.osdetail.html
	$AWS -config=$i -output=unknownbrowser -lang=es -staticlinks > $OUT/awstats.$i.unknownbrowser.html
	$AWS -config=$i -output=unknownos -lang=es -staticlinks > $OUT/awstats.$i.unknownos.html
	$AWS -config=$i -output=refererse -lang=es -staticlinks > $OUT/awstats.$i.refererse.html
	$AWS -config=$i -output=refererpages -lang=es -staticlinks > $OUT/awstats.$i.refererpages.html
	$AWS -config=$i -output=keyphrases -lang=es -staticlinks > $OUT/awstats.$i.keyphrases.html
	$AWS -config=$i -output=keywords -lang=es -staticlinks > $OUT/awstats.$i.keywords.html
	$AWS -config=$i -output=errors404 -lang=es -staticlinks > $OUT/awstats.$i.errors404.html
		    	    
	# Crear un index:
	cp $APP/data/index.php $OUT/.
	# Ajustar permisos:
	chown -R apache:apache $OUT
done

# Borrar el log de apache usado:
rm -f $FTMP
decir $VERDE"\n> Finalizado.\n"$NORMAL
echo $(date +"[%d-%m-%Y@%H:%M:%S]")" Finalizado." >> /var/log/admin/awstats.log

