#!/usr/bin/php -q
<?php
# banner.php
# queru@qaop.com
	
require("phpfiglet_class.php");

# Quitar errores en html:
ini_set("html_errors", false);
# Que no se detenga la ejecución por tiempo:
set_time_limit(0);

# Si no hay argumentos:
if ($_SERVER['argc'] < 2)
{
	echo "\nUtilización: banner.php \"texto\" [fuente]\n";
	echo "Las fuentes son los archivos '.flf' del directorio 'fonts'.\n\n";
	die;
}

$texto = $_SERVER['argv'][1];
if (empty($_SERVER['argv'][2]))
{
	$fuente = "standard";
}
else
{
	$fuente = $_SERVER['argv'][2];
}

$phpFiglet = new phpFiglet();

if ($phpFiglet->loadFont("/usr/local/admin/phpBanner/fonts/".$fuente.".flf")) {
	$phpFiglet->display($texto);
} else {
	trigger_error("Error cargando la fuente.");
}
?>
