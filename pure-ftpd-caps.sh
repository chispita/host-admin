#!/bin/bash

VEID=115

echo "Otorgando capabilities a VE $VEID.."

for CAP in CHOWN DAC_READ_SEARCH SETGID SETUID NET_BIND_SERVICE NET_ADMIN SYS_CHROOT SYS_NICE CHOWN DAC_READ_SEARCH SETGID SETUID NET_BIND_SERVICE NET_ADMIN SYS_CHROOT SYS_NICE
do
	echo "- $CAP"
	vzctl set $VEID --capability ${CAP}:on --save
done

echo "Finalizado."

