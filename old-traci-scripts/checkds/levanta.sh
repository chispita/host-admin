#!/bin/bash

# Parada:
/etc/init.d/$1 stop
sleep 1
killall -9 $1 &> /dev/null
sleep 1
killall -9 $1 &> /dev/null

# Zap:
/etc/init.d/$1 zap

# Start:
/etc/init.d/$1 start

# Salida con estado:
ps -A|grep $1 &> /dev/null
exit $?

