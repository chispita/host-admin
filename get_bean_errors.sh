#!/bin/bash

for i in $(ls -C1 /proc/bc | egrep -v "^0|resources")
do
	cat /proc/bc/$i/resources | tr -s " " "|" | sed "s/^\|/$i/" | egrep -v "\|0$"
done

