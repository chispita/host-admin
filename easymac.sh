#!/bin/sh
# Script for generating VMware MAC Addresses
# http://www.easyvmx.com
#
# Works on any *NIX system with /dev/urandom
#
# Freely distributable under the BSD license:
#
# ------------- Start licence --------------
# Copyright (c) 2006, http://www.easyvmx.com
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# Neither the name of the <ORGANIZATION> nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# ------------- End licence --------------
#
# Changelog
# ---------
# 2006-11-06:
#	Version 1.0, first release of EasyMAC!
#
# 2007-07-20:
#	Version 1.1:
#		Added option for _any_ MAC address, not only VMware addresses.
#		Changed output for static/random MAC address. It now tells that these are VMware MAC adresses.


# 
# Version
#

EMVersion=1.1
ReleaseYear=2007
ReleaseDate=2007-07-20


#
# Functions
#

# Random MAC Address
random() {
	randmac=$(dd if=/dev/urandom bs=1 count=3 2>/dev/null | od -tx1 | head -1 | cut -d' ' -f2- | awk '{ print "00:0c:29:"$1":"$2":"$3 }')
	echo $randmac
}

# Static MAC Address
static() {
	max3f=$(printf "%02X" $(expr $(dd if=/dev/urandom bs=1 count=1 2>/dev/null | od -tu1 | head -1 | cut -d' ' -f2-) / 4) | tr A-Z a-z)
	statmac=$(echo -n "00:50:56:$max3f:" $(dd if=/dev/urandom bs=1 count=2 2>/dev/null | od -tx1 | head -1 | cut -d' ' -f2- | awk '{ print $1":"$2 }') | sed 's/\ //')
	echo $statmac
}

# Global  MAC Address
global() {
        globalmac=$(dd if=/dev/urandom bs=1 count=6 2>/dev/null | od -tx1 | head -1 | cut -d' ' -f2- | awk '{ print $1":"$2":"$3":"$4":"$5":"$6 }')
        echo $globalmac
}



#
# Process options
#

case "$1" in

	r|-r|random|-random)
		echo -n "Random VMware MAC Address: "
		random
		echo ""
		;;

	R|-R|RANDOM|-RANDOM|Random|-Random)
		echo -n "Random VMware MAC Address: "
		random | tr a-z A-Z
		echo ""
		;;

	s|-s|static|-static)
		echo -n "Static VMware MAC Address: "
		static
		echo ""
		;;

	S|-S|STATIC|-STATIC|Static|-Static)
		echo -n "Static VMware MAC Address: "
		static | tr a-z A-Z
		echo ""
		;;

	g|-g|global|-global)
		echo -n "Global MAC Address: "
		global
		echo ""
		;;

	G|-G|GLOBAL|-GLOBAL|Global|-Global)
		echo -n "Global MAC Address: "
		global | tr a-z A-Z
		echo ""
		;;

	*)
		echo ""
		echo "EasyMAC! v. $EMVersion"
		echo "Generate hardware adresses for virtual machines"
		echo "Copyright (c) $ReleaseYear, http://www.easyvmx.com"
		echo ""
		echo "Usage: $0 {-r|-R|-s|-S}"
		echo ""
		echo "Options:"
		echo "   -r:	Random VMware MAC address, lower case"	
		echo "   -R:	Random VMware MAC address, UPPER CASE"	
		echo "   -s:	Static VMware MAC address, lower case"	
		echo "   -S:	Static VMware MAC address, UPPER CASE"	
		echo "   -g:	Global MAC address, lower case"
		echo "   -G:	Global MAC address, UPPER CASE"
		echo ""
		echo "All valid options:"
		echo "   Random VMware Lower Case: 	{r|-r|random|-random}"
		echo "   Random VMware Upper Case: 	{R|-R|RANDOM|-RANDOM|Random|-Random}"
		echo "   Static VMware Lower Case: 	{s|-s|static|-static}"
		echo "   Static VMware Upper Case: 	{S|-S|STATIC|-STATIC|Static|-Static}"
		echo "   Global MAC Lower case:	{g|-g|global|-global}"
		echo "   Global MAC Upper case:	{G|-G|GLOBAL|-GLOBAL|Global|-Global}"
		echo ""
		echo "Freely distributable under the BSD license"
		echo "Visit http://www.easyvmx.com for the best online virtual machine creator!"
		echo ""
		exit 1

esac

exit $?
