#!/bin/bash

# ---[Includes]---

source /usr/local/admin/include/funciones.inc.sh

# ---[FUNCIONES]---

function activa_nfs()
{
	# Activar los NFS:
	haciendo "Matando rpc.statd"
	killall -9 rpc.statd &> /dev/null
	ok 0
	haciendo "Reiniciando portmap"
	/etc/init.d/portmap restart &> /dev/null
	ok $?
	haciendo "Activando NFS"
	/etc/init.d/nfs-common restart &> /dev/null
	RES=$?
	ok $RES
	if [ $RES -ne 0 ]
	then
		errorgrave "Error activando NFS"
	fi
	# Reiniciar servidor NFS:
	haciendo "Reiniciando servidor NFS en nodo1"
	ssh root@nodo1.traci.es /etc/init.d/nfs-kernel-server restart &> /dev/null
	RES=$?
	ok $RES
	if [ $RES -ne 0 ]
	then
		errorgrave "Error reiniciando servidor NFS"
	fi
}

function para_nfs()
{
	# Parar NFS:
	haciendo "Matando rpc.statd"
	killall -9 rpc.statd &> /dev/null
	ok 0
	haciendo "Parando portmap"
	/etc/init.d/portmap stop &> /dev/null
	ok $?
	haciendo "Parando NFS-common"
	/etc/init.d/nfs-common stop &> /dev/null
	ok $?
	haciendo "Parando servidor NFS en nodo1"
	ssh root@nodo1.traci.es /etc/init.d/nfs-kernel-server stop &> /dev/null
	ok $?
}

function activa_vg()
{
	if [[ "$HOSTNAME" == "simone.traci.es" ]]
	then
		# En simone se monta por NFS
		# Asegurando montaje en nodo1:
		informa "Asegurando montaje en nodo1"
		ssh root@nodo1.traci.es /usr/local/admin/monta_cabina.sh
		# No hay que activar VGs pero si NFS.
		activa_nfs
	else
		# Activar los VGs:
		haciendo "Activando VGs"
		echo
		vgchange -ay
		RES=$?
		ok $RES
		if [ $RES -ne 0 ]
		then
			errorgrave "Error activando Volume Groups"
		fi
	fi
}

function monta_cabina()
{
	# Montar el BackUp:
	haciendo "Montando cabina"
	mount /backup
	RES=$?
	ok $RES
	if [ $RES -ne 0 ]
	then
		errorgrave "Error montando cabina"
	fi
}

function desmonta_cabina()
{
	# Montar el BackUp:
	haciendo "Desmontando cabina"
	umount -f /backup &> /dev/null
	RES=$?
	ok $RES
	if [ $RES -ne 0 ]
	then
		aviso "Error desmontando cabina"
	fi
}

# ---[CONFIGURACIÓN]---

CTRL="/backup/.control-montaje"
CTRL_LAST="/backup/.control-last"
HOSTNAME=$(hostname -f)

# ---[MAIN]---

titulo "Comprobando cabina backup"
informa "NODO: $HOSTNAME"
# Comprobando si la cabina está montada:
mount | grep "on /backup" &> /dev/null
if [ $? -eq 0 ]
then
	# Montada ok.
	informa "Montada ok."
	# Comprobamos que se pueda leer.
	if [ -f $CTRL ]
	then
		# Lee directorio ok.
		informa "Directorio ok."
		# Probando escritura:
		FECHA=$(date +"%s")
		echo $FECHA > $CTRL_LAST
		if [ $? -eq 0 ]
		then
			informa "Escritura ok."
			# Probando lectura:
			LECT=$(cat $CTRL_LAST)
			if [[ "$LECT" == "$FECHA" ]]
			then
				# Coincide:
				informa "Lectura ok."
			else
				# ERROR lectura:
				aviso "Error de lectura."
				para_nfs
				desmonta_cabina
				activa_vg
				monta_cabina
				activa_nfs
			fi
		else
			# Error de escritura.
			aviso "Error de escritura"
			para_nfs
			desmonta_cabina
			activa_vg
			monta_cabina
			activa_nfs
		fi
	else
		# Aparece montada pero no se puede
		# leer. Desmontamos y montamos.
		aviso "No se puede leer"
		para_nfs
		desmonta_cabina
		activa_vg
		monta_cabina
		activa_nfs
	fi
else
	# No está montada.
	aviso "No está montada"
	para_nfs
	activa_vg
	monta_cabina
	activa_nfs
fi

# Salida:
finalizado 0


