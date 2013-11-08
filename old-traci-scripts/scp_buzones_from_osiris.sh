#!/bin/bash

# Este es un ejemplo para pasar buzones desde una tabla de vpopmail a postfix.
# El dominio debe existir ya.

DOM=$1

echo "> Traspasando buzones de $1 desde osiris..."

for i in $(ssh osiris.qaop.com ls -c1 /home/vpopmail/domains/$1)
do
	CASA="/home/vpopmail/domains/"$1"/"$i
	echo "  - Maildir.: $CASA"
	mkdir -p /var/spool/mail/$DOM/Maildir
	scp -r root@osiris.qaop.com:$CASA/Maildir/new /var/spool/mail/$DOM/Maildir/new
	scp -r root@osiris.qaop.com:$CASA/Maildir/cur /var/spool/mail/$DOM/Maildir/cur
	scp -r root@osiris.qaop.com:$CASA/Maildir/tmp /var/spool/mail/$DOM/Maildir/new
	scp root@osiris.qaop.com:$CASA/Maildir/maildirsize /var/spool/mail/$DOM/Maildir/maildirsize
	chown -R 10000:10000 /var/spool/mail/$DOM
done

echo "> Fin de traspaso."
