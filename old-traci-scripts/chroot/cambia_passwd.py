#!/bin/env python
# -*- coding: ISO-8859-15 -*-

# ------------------------------------------------------------
#  Cambia la password de un usuario sin necesdad de
#  interacción. queru@queru.org - 2005
# ------------------------------------------------------------

import pexpect, sys, time

# Argumentos:
if len(sys.argv) < 2:
	print "¡Faltan argumentos!"
	print "<usuario> <pass>"
	sys.exit(1)

cUsu  = sys.argv[1]
cPass = sys.argv[2]

# Logs:
fLog = open('/var/log/admin/cambia_passwd.log', 'w')


print "\t\t# passwd "+cUsu+" "+cPass
try:
	pwd = pexpect.spawn("passwd "+cUsu)
	pwd.setlog(fLog)
	time.sleep(0.1)
	pwd.expect("password: ", timeout=5)
	time.sleep(0.1)
	pwd.sendline(cPass)
	time.sleep(0.1)
	pwd.expect("password: ", timeout=5)
	time.sleep(0.1)
	pwd.sendline(cPass)
	pwd.expect("successfully", timeout=5)
except:
	print "ERROR"
	sys.exit(1)
