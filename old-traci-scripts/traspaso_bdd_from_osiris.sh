#!/bin/bash

OSIRIS_BDD=$1
DOMTRACI=$2

echo "BDD: $OSIRIS_BDD"
echo "USU: $DOMTRACI"

echo "  - Exportando BDD..."
echo -e "CREATE DATABASE $OSIRIS_BDD;\nUSE $OSIRIS_BDD;\n\n" > /tmp/$OSIRIS_BDD-export.sql
mysqldump --host="osiris.qaop.com" --user="toor" --password="toorsql" $OSIRIS_BDD >> /tmp/$OSIRIS_BDD-export.sql
echo "  - Importando BDD -> $OSIRIS_BDD..."
cat /tmp/$OSIRIS_BDD-export.sql | mysql
rm /tmp/$OSIRIS_BDD-export.sql
echo "  - Permisos de la BDD..."
echo "INSERT INTO mysql.db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Grant_priv,References_priv, \
	Index_priv,Alter_priv,Create_tmp_table_priv,Lock_tables_priv) \
	VALUES ('localhost', '$OSIRIS_BDD', '$DOMTRACI', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'Y', 'Y');" | mysql
echo "FLUSH PRIVILEGES;" | mysql
