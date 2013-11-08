#!/bin/bash
#########################################################333
# Description: Change memory in openvz machines
#     Creator: Carlos Val Gascon
#        Date: JAN/17/2013
#########################################################333

EXPECTED_ARGS=3
cid=$1
LOWMEMORY=$2
MAXMEMORY=$3

services=( 'kmemsize' 'lockedpages' 'vmguarpages' 'oomguarpages' 'privvmpages' 'shmpages' 'physpages' )

if [ $# -lt $EXPECTED_ARGS ]
then
  echo "vzctl_automentarmemoria- ©2013 Carlos Val (carlos.val.gascon@gmail.com)"
  echo
  echo "Change memory in openvz machines"
  echo
  echo "Use:"
  echo "  $0 <machine_id> <lowmemory> <maxmemory>"
  echo "Example: $0 101 1024 1024"
  echo
  exit 1
fi



for i in "${services[@]}"
do
  printf "Procesando ${1}...\n"

  vzctl set ${cid} --${i}  ${LOWMEMORY}G:${MAXMEMORY}G --save
done

