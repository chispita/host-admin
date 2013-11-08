#!/bin/bash

# Mantiene una lista actualizada de administradores
# de dominios de conectahosting.

for i in $(ls -C1 /web/domains|grep -v "194.143.194.244")
do
	ALIAS=$ALIAS"postmaster@$i,webmaster@$i,"
done

echo "UPDATE cqtraci.alias SET goto='$ALIAS' WHERE address='webmasters@conectahosting.com' LIMIT 1;" | mysql

