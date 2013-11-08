#!/bin/sh

MARCATEMP=$(date +"%d%h%Y_%H%M%S")
OUT="BackUp_MySQL_$MARCATEMP.sql"

echo "Volcando backup a $OUT..."

mysqldump \
	-hlocalhost \
	--all-databases \
	--all \
	--opt \
	--allow-keywords \
	--hex-blob \
	--master-data \
	--quote-names \
	--max_allowed_packet=16M \
	--result-file=$OUT

echo "Comprimiendo..."

gzip $OUT

echo "Finalizado."

