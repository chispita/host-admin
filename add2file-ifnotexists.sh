#!/bin/bash

# <texto> <fichero>
# A�ade <texto> a <fichero> si no est� ya en �l.

cat $2 | egrep "^$1$" &> /dev/null
if [ $? -eq 0 ]
then
	echo -n 'YA EXISTE...'
	exit 2
else
	echo "${1}" >> $2
fi

exit 0
