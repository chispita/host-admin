#!/bin/bash

# ----------------------------------------
# Backups diferenciales de Traci.qaop.com.
# queru@qaop.com - Julio de 2004.
# ----------------------------------------

# Configuración:
# Localización de rdiff-backup:
RDIFF="/usr/bin/rdiff-backup"
# Parámetros de ejecución:
OPCIONES="--force -v2"
# Tiempo de conservación de ficheros borrados en el master:
OLD="1M"
# Nombre del host:
HOST="traci.qaop.com"
# Fichero con la lista de directorios a respaldar:
BKFILE="/usr/local/admin/local_backup_dirs_list.txt"
# Disco de backups:
HDBK="/mnt/backup"
# Mail para los avisos:
MAIL="sistemas@qaop.com"

# Funciones:
# Gestion de errores:
error_grave()
{
	echo "*** ERROR GRAVE. BACKUP ABORTADO ***"
	echo "*** ERROR GRAVE. BACKUP ABORTADO ***" | mail -s "ERROR BACKUP: $HOST" sistemas@qaop.com
	exit 1
}

error_leve()
{
	echo "*** ERROR LEVE. BACKUP CONTINUA ***"
	echo "*** ERROR LEVE. BACKUP CONTINUA ***" | mail -s "ERROR BACKUP: $HOST" sistemas@qaop.com
}

echo "======================================================================================"
echo "+ Backup $HOST"
echo "======================================================================================"
echo "> Montando disco de backup..."
/usr/local/admin/montabk.sh
if [ "$?" -eq "1" ]; then
	error_leve
	exit 1
fi

# Crear directorio gral. de backup, si no existe:
mkdir -p $HDBK/$HOST &> /dev/null
# Componer la lista de directorios a respaldar:
BKLIST=`cat $BKFILE|grep -v "#"|grep -v -e "^[[:space:]]*$"|sort -u`

echo -e "\n+ RESPALDANDO:\n"
for i in $BKLIST
do
	echo "> Respaldando $i"
	mkdir -p $HDBK/$HOST/$i
	$RDIFF $OPCIONES $i $HDBK/$HOST/$i
	if [ "$?" -eq "1" ]; then
		error_grave
	fi
done

echo -e "\n+ HISTóRICOS:\n"
for i in $BKLIST
do
        echo "> Borrando histórico (>$OLD) $i"
	$RDIFF $OPCIONES --remove-older-than $OLD $HDBK/$HOST/$i
done
	
echo -e "\n+ FINALIZANDO.\n"
echo -e "> Sincronizando discos."
sync
echo "> Estadística:"
df -h $HDBK
echo "> Desmontando disco de backup..."
/usr/local/admin/desmontabk.sh
echo -e "\n+ OK\n"

