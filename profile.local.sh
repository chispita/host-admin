#!/bin/bash

# Profile local ligero v2.0
# queru@queru.org - Dic 2007

# Si no hay terminal definido no diremos nada por pantalla:
if [ -n "${TERM}" ]
then
	VERBOSO=1
else
	VERBOSO=0
fi

source /usr/local/admin/include/colores.inc.sh

# PATH:
export PATH="$PATH:/usr/local/admin"
# ENTORNO:
export VZROOT="/var/lib/vz"
export LANG="es_ES.UTF-8"
export LANGUAGE="es_ES.UTF-8"
export LC_ALL="es_ES.UTF-8"
export TZ="Europe/Madrid"
export HISTFILE="${HOME}/.bash_history"

USUARIO=$(whoami)
if [ $USUARIO == "root" ]
then
	# Averiguar tipo y número de máquina OVZ y
	# ajustar el prompt para indicarlo:
	cat /proc/vz/veinfo |egrep "^\ *0" &> /dev/null
	if [ $? -eq 0 ]
	then
		TIPOMAQUINA="HOST"
		export PS1="\e[s\e[2;0H\e[1m\e[30;41m **CUIDADO: ESTO ES UN HOST** (\h) \e[0m\e[u\e[31m${TIPOMAQUINA}\e[0m\e[34m[\e[36m\u\e[34m@\e[34m\e[35m\h\e[34m]\e[33m\w\e[0m:\n--> "
	else
		TIPOMAQUINA="VE"
		# Pillar número de VE:
		NUMVE=$(cat /proc/vz/veinfo|tr -s " " "|"|cut -f2 -d"|")
		export PS1="\e[32m${TIPOMAQUINA}\e[0m${NUMVE}\e[34m[\e[36m\u\e[34m@\e[34m\e[35m\h\e[34m]\e[33m\w\e[0m:\n--> "
	fi
else
	export PS1="\e[34m[\e[36m\u\e[34m@\e[34m\e[35m\h\e[34m]\e[33m\w\e[0m:\n--> "
fi

if [ $VERBOSO -eq 1 ]
then
	# Username:
	QUIEN=$(whoami)

	# Comandos info, Debian 4.0:
	FECHA=$(date +"%T@%d-%m-%Y")
	LASTLOG=$(lastlog -u $(id -un)|tail -n1|cut -c44-80)
	UPTIME=$(uptime|cut -f 1 -d",")
	FQDN=$(hostname -f)" ("$(hostname -i)")"

	# Separadores:
	GUIONES=$AZUL"-------------------------------------------------------------------------------"$NORMAL
	PUNTOS=$AZUL"..............................................................................."$NORMAL

	# Barra del xterm:
	echo -e "\e]2;---=:["`whoami`"@$(hostname -f) :¬)]:=---\a"
	# Borrar pantalla:
	clear
	# saludo:
	echo -e $GUIONES
	# Banner (generar con phpBanner o similar):
	cat /usr/local/admin/hostname.banner
	echo " "$FQDN
	# Datos sistema:
	echo -e "$CYAN+++ "$VERDE"Hola $ROJO$QUIEN,$VERDE bienvenido a $MAGENTA$(hostname -f) $CYAN+++$NORMAL"
	echo -e $PUNTOS
	echo -e $VERDE"Fecha.............: "$CYAN$FECHA$NORMAL
	echo -e $VERDE"Uptime............:"$CYAN$UPTIME$NORMAL
	echo -e $VERDE"Ultimo acceso.....: "$CYAN$LASTLOG$NORMAL

	# RAM:
	RAM=`cat /proc/meminfo|grep "MemTotal"|cut -f2 -d":"`
	RAM=`echo $RAM|cut -f1 -d" "`
	RAM=`expr $RAM / 1024`
	FREE=`cat /proc/meminfo|grep "MemFree"|cut -f2 -d":"`
	FREE=`echo $FREE|cut -f1 -d" "`
	FREE=`expr $FREE / 1024`

	echo -e $VERDE"Memoria RAM.......:"$CYAN" "$RAM"Mb total, libres "$FREE"Mb"$NORMAL

	echo -e $PUNTOS
	echo -en $MARRON
	cat /etc/issue.net
	uname -a
	echo -en $NORMAL
	echo -e $GUIONES
fi

# Alias adicionales:
alias ls='ls --color'
alias la='ls -laihF --color'
alias cdadmin='cd /usr/local/admin'
alias grep='grep --color=auto'

alias mkdir='mkdir -pv'
alias h='history'
alias j='jobs -1'


if [ "$TIPOMAQUINA" == "HOST" ]
then
	# Alias adicionales:
	alias apt-get="/usr/local/admin/fake-apt-get.sh"
	alias aptitude="/usr/local/admin/fake-aptitude.sh"
	
	# Funciones exportadas:
	function cdvz()
	{
		echo -e "\n$AZUL***$BLANCO Directorio raíz de container $VERDE$1$AZUL ***$NORMAL\n"
		cd "/var/lib/vz/private/$1"
	}
	export -f cdvz
	function vze()
	{
		if [[ $1 != ${1//[^0-9]/} ]]
		then
			CTID=$(vzlist|tr -s " " "|"|grep -v "VEID"|grep "${1}."|cut -f2 -d"|")
			if [[ $CTID != ${CTID//[^0-9]/} ]]
			then
				echo -e "\n$ROJO> ERROR$NORMAL No se encuentra el container ${1}:"
				vzlist|tr -s " " "|"|grep -v "VEID"|grep "${1}."
				return 1
			fi
		else
			CTID=$1
		fi

		if [ -d "/var/lib/vz/private/$CTID" ]
		then
			echo -e "\n$AZUL>$BLANCO Entrando en container $VERDE$CTID$NORMAL...\n"
			sleep 1
			vzctl enter "${CTID}"
			echo -e "\n$AZUL>$BLANCO Bienvenido de nuevo al ${VERDE}HOST${NORMAL} ${CYAN}$(hostname -f)${NORMAL}...\n"
		else
			echo -e "\n$ROJO> ERROR$NORMAL El container $BLANCO$1$NORMAL no existe en este host."
			echo -e "${BLANCO}>${NORMAL} Pruebe: ${BLANCO}vz list${NORMAL}\n"
		fi
	}
	export -f vze
	if [ $VERBOSO -eq 1 ]
	then
		echo "> Alias: la, cdadmin, vze, cdvz."
	fi 
else
	if [ $VERBOSO -eq 1 ]
	then
		echo "> Alias: la, cdadmin."
	fi
fi

if [ $USUARIO == "root" ]
then
	cd /root
fi

if [ $VERBOSO -eq 1 ]
then
	echo "> profile local..."
fi

# El profile del usuario si tiene:
if [ -f ~/.profile ]
then
	source ~/.profile
fi

