#!/bin/bash

# Crea usuarios para ftp en la BDD.
# Queru y Calocén - Enero 2005.

source /usr/local/admin/colores.inc

echo -e $CYAN"\n+ ALTA DE USUARIO FTP:\n"$NORMAL

if [ -z "$1" ]
then
	echo -e "    - "$VERDE"Usuario:"$BLANCO" \c"
	read USU
else
	echo -e "    - "$VERDE"Usuario: "$BLANCO$1
	USU=$1
fi

if [ -z "$USU" ]
then
	echo -e $ROJO"\n¡Usuario vacío!$NORMAL\n"
	exit 1
fi

DATOS=$(echo "select * from cqtraci.ftp where name='$USU';"|mysql)
if [ -n "$DATOS" ]
then
        echo -e $ROJO"\nERROR: El usuario ya existe.\n"$NORMAL
	exit 1
fi

# PASS:
if [ -z "$2" ]
then
	echo -e "    - "$VERDE"Password:"$BLANCO" \c"
	read PASS
else
        echo -e "    - "$VERDE"Password: "$BLANCO$2
        PASS=$2
fi

# HOME:
if [ -z "$3" ]
then
	echo -e "    - "$VERDE"Dir.home:"$BLANCO" \c"
	read DIRHOME
else
	echo -e "    - "$VERDE"Dir.home: "$BLANCO$3
	DIRHOME=$3
fi

if [ -z "$DIRHOME" ]
then
	echo -e $ROJO"\n¡Home vacío!$NORMAL\n"
	exit 1
fi

# UID:
FTPUID=$(echo "SELECT MAX(uid)+1 FROM cqtraci.ftp;" | mysql | tail -n 1)
if [ -z "$4" ]
then
	echo -e "    - "$VERDE"UID ($FTPUID):"$BLANCO" \c"
	read RFTPUID
	if [ -n "$RFTPUID" ]
	then
		FTPUID=$RFTPUID
	fi
else
        echo -e "    - "$VERDE"UID: "$BLANCO$4
        FTPUID=$4
fi

# GID:
FTPGID=$FTPUID
if [ -z "$5" ]
then
	echo -e "    - "$VERDE"GID ($FTPGID):"$BLANCO" \c"
	read RFTPGID
	if [ -n "$RFTPGID" ]
	then
		FTPGID=$RFTPGID
	fi
else
        echo -e "    - "$VERDE"GID: "$BLANCO$5
        FTPGID=$5
fi

# COUTA:
if [ -z "$6" ]
then
        echo -e "    - "$VERDE"CUOTA (50Mb):"$BLANCO" \c"
	read CUOTA
	if [ -z $CUOTA ]
	then
		CUOTA=50
	fi
else
        echo -e "    - "$VERDE"CUOTA: "$BLANCO$6
	CUOTA=$6
fi

echo -e "\n$BLANCO> $AMARILLO¿Confirma que desea dar de alta el usuario? (S/n):$BLANCO \c"
read -n1 SINO
if [ -z "$SINO" ]
then
	SINO="s"
fi
if [ "$SINO" == "S" ]
then
	SINO="S"
fi
if [ "$SINO" != "s" ]
then
        echo -e $AMARILLO"\n\n*** ABORTADO ***\n"$NORMAL
        exit 1
fi

echo -e "\n"$BLANCO"> "$VERDE"Creando usuario $BLANCO$USU$NORMAL..."
			

echo "INSERT INTO cqtraci.ftp (name,uid,gid,pwd,home,quota,domain) \
        VALUES ('$USU','$FTPUID','$FTPUID','$PASS','$DIRHOME','$CUOTA','Usuario independiente');" | mysql

echo -e $AZUL"\n> Finalizado.\n"$NORMAL

