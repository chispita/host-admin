#!/bin/bash

# Mata todo los procesos de un container
# A lo bruto y sin preguntar.

source /usr/local/admin/include/funciones.inc.sh

titulo "Matando container $1"

informa "Intentnado resume"
vzctl chkpnt $i --resume
informa "Intentando stop"
vzctl stop $1

informa "Matando procesos a lo bestia"

for proceso in $(
	for i in $(ps aux|tr -s " " "|"|cut -f2 -d"|")
	do
		vzpid $i | grep -v "VEID" | tr -s "\t" "|" | grep "|$1|"
      	done)
do
	PID=$(echo $proceso|cut -f1 -d"|")
	NOMBRE=$(echo $proceso|cut -f3 -d"|")
	haciendo "Matando $NOMBRE ($PID)..."
	kill -KILL $PID
	ok $?
done

informa "STOP de nuevo"
vzctl stop 110

