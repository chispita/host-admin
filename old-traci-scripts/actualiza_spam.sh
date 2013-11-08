#!/bin/bash
# actualiza_spam.sh
# Script para aÃadir a la base de datos spam el contenido de los correos
# recibidos en spam@qaop.com

pushd /var/spool/mail/qaop.com/spam >/dev/null
[ -f new/* ] 2>/dev/null
if [ $? -eq 1 ] ; then exit 1 ; fi
a=`/usr/bin/sa-learn --spam --dir new`
logger -t spam $a
for i in new/*
do
	mv $i cur/ >/dev/null
done
popd >/dev/null

