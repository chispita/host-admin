#!/bin/bash

# desmonta_chroots.sh
# Desmanta todos los chroots montados.

for i in `mount|grep "chroot-env.iso"|cut -f1 -d" "`
do
	echo "Desmontando $i"
	umount $i
done

