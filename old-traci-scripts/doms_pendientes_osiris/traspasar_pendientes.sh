#!/bin/bash

for i in $(./check.sh)
do
	echo " "
	echo "Quedan $(./check.sh|wc -l) dominios."
	echo "Traspaso de $i"
	echo -n "[CONT...]"
	read
	traspaso_total_from_osiris.sh $i
done
