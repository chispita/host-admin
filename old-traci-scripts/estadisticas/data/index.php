<?php
	# Quitamos el www. si lo tiene:
	$dominio = eregi_replace("^www\.", "", $_SERVER['HTTP_HOST']);

	# Nos aseguramos de que está en minúsculas:
	$dominio = strtolower($dominio);

	# Cargamos el índice de las estadísticas:
	include "awstats.".$dominio.".html";
?>
