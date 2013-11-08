#!/bin/bash

# Este es un ejemplo para pasar buzones desde una tabla de vpopmail a postfix.
# El dominio debe existir ya.

TABLA="vpopmail.vpopmail"
DOM=$1

echo "> Traspasando buzones de $1 desde osiris..."

for i in $(echo "SELECT pw_name FROM $TABLA WHERE pw_domain='$DOM' and pw_name<>'postmaster';"|mysql -h osiris.qaop.com --user=toor --password=toorsql -N)
do
	echo "+ Añadiendo $i:"
	BUZON="$i@$DOM"
	echo "  - Buzón...: $BUZON"
	PASS=$(echo "select pw_clear_passwd from $TABLA where pw_name='$i' and pw_domain='$DOM';" | \
		mysql -h osiris.qaop.com --user=toor --password=toorsql -N)
	CASA=$(echo "select pw_dir from $TABLA where pw_name='$i' and pw_domain='$DOM';" | \
		mysql -h osiris.qaop.com --user=toor --password=toorsql -N)
	echo "  - Pass....: $PASS"
	echo "  - Maildir.: $CASA"
	echo "INSERT INTO cqtraci.mailbox (username, password, name, maildir, quota, domain, created, modified, active) \
		VALUES ('$BUZON','$PASS','$i','$DOM/$i/',104857600,'$DOM',NOW(),NOW(),1);" | mysql
	echo "INSERT INTO cqtraci.alias (address, goto, domain, created, modified, active) 
		VALUES ('$BUZON','$BUZON','$DOM',NOW(),NOW(),1);" | mysql
	mkdir -p /var/spool/mail/$DOM/$i/Maildir
	scp -qr root@osiris.qaop.com:$CASA/Maildir/new /var/spool/mail/$DOM/$i/Maildir/new
	scp -qr root@osiris.qaop.com:$CASA/Maildir/cur /var/spool/mail/$DOM/$i/Maildir/cur
	scp -qr root@osiris.qaop.com:$CASA/Maildir/tmp /var/spool/mail/$DOM/$i/Maildir/new
	scp -q root@osiris.qaop.com:$CASA/Maildir/maildirsize /var/spool/mail/$DOM/$i/Maildir/maildirsize
	chown -R 10000:10000 /var/spool/mail/$DOM
	echo "Buzón activado." | mail -s "Activación de buzón." $BUZON
done

echo "> Fin de traspaso."
