#!/bin/bash

wget "http://www.aragoneame.com/blogliticos/wp-content/plugins/wp-o-matic/cron.php?code=90a155bf" -O - &> /dev/null
if [ $? -ne 0 ]
then
	echo "ERROR actualizando aragonéame."
	exit 1
fi

