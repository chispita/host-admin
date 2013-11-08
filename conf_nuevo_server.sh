#!/bin/bash

echo "Configurando nuevo servidor Conectahosting:"
echo "==========================================="

echo "¿FQDN? "
read FQDN

HOSTNAME=$(echo $FQDN|cut -f1 -d".")

echo "> Copiar las keys. Tendrá que teclear la password quizá varias veces..."
ssh root@$FQDN mkdir -p /root/.ssh
ssh root@$FQDN ssh-keygen
scp /root/.ssh/authorized_keys root@$FQDN:/root/.ssh/.

echo "> Copiando configuración sshd:"
scp /etc/ssh/sshd_config root@$FQDN:/etc/ssh/.

echo "> Reiniciando sshd..."
ssh root@$FQDN /etc/init.d/ssh restart

echo "> Copiando admin y profiles..."
ssh root@$FQDN mkdir -p /usr/local/admin
scp -r /usr/local/admin/. root@$FQDN:/usr/local/admin/.
scp /etc/profile root@$FQDN:/etc/.
scp /root/.bashrc root@$FQDN:/root/.bashrc

echo "> Banner..."
/usr/local/admin/banner $HOSTNAME > /tmp/hostname.banner
cat /tmp/hostname.banner
scp /tmp/hostname.banner root@$FQDN:/usr/local/admin/.

echo "> Configuraciones varias..."
scp /etc/vim/vimrc root@$FQDN:/etc/vim/.

echo "> Repositorios OpenVZ:"
ssh root@FQDN -C echo "deb http://download.openvz.org/debian-systs etch openvz" >> /etc/apt/sources.list
ssh root@FQDN -C wget -q http://download.openvz.org/debian-systs/dso_archiv_signing_key.asc -O- | apt-key add - && apt-get update

