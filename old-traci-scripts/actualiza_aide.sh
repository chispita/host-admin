#!/bin/bash

AIDEDIR="/usr/local/admin/aide"

echo "Actualizando base de datos..."

aide -u

echo "OK"
echo "Sobreescribiendo bdd anterior..."

cp -f $AIDEDIR/aide.db.new $AIDEDIR/aide.db

echo "Finalizado."

