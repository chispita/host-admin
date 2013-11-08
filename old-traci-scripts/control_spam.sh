#/bin/bash
# actualizacion de la base de datos de spam
# actualizacion del spam
cd /var/spool/mail/qaop.com/spam/new
for i in *
do
	sa-learn --spam $i > /dev/null
	mv $i ../cur/ 
done

# actualizacion del ham
cd /var/spool/mail/qaop.com/ham/new
for i in *
do
	sa-learn --forget --ham $i > /dev/null
	mv $i ../cur/ 
done

