#!/bin/bash

echo "Borrando known_hosts"
rm /root/.ssh/known_hosts

echo "SSH:"

ssh root@simone.traci.es
ssh root@nodo1.traci.es
ssh root@nodo2.traci.es
ssh root@nodo3.traci.es

echo "-----"
echo " FIN"
echo "-----"
