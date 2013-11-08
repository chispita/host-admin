#!/usr/bin/php -q
<?php

# ---------------------------------------------------------------------
# mantenimiento_logs_apache.php
# Parte de: apachelogs2mysql.php
#
# Realiza un mantenimiento de las tablas de logs de apache.
#
# queru@queru.org - Enero 2006.
# ---------------------------------------------------------------------

# Quitar errores en html:
ini_set("html_errors", false);
# Que no se detenga la ejecuci�n por tiempo:
set_time_limit(0);

# Configuraci�n:
# ---------------------------------------------------------------------
# Fichero de logs:
define("LOGFIC", "/var/log/apache2/mantenimiento_logs_apache.log");
# Escribir informaci�n de debug:
define("DEBUG", false);
# Eco al terminal:
define("ECO", true);
# Configuraci�n MySQL:
define("MYHOST", "localhost");
define("MYUSER", "httpdlogger");
define("MYPASS", "h77pd_l0gg3r");
define("MYDB", "cqtraci_logs");
# Localicaci�n de las carpetas web de los vhosts din�micos:
define("DOMS", "/web/domains");
# Los que est�n en NOLOG son descartados:
define("NOLOG", "pumbo.com, 3djuegos.com, solodemos.com, demoindex.com");
# ---------------------------------------------------------------------
# FIN de config.

loguea("Inicio de proceso de mantenimiento de tablas.");
if (DEBUG)
{
	loguea("Debug ACTIVADO.");
}
else
{
	loguea("Debug desactivado.");
}

# Conexi�n con BDD:
$dbcon = @mysql_connect(MYHOST, MYUSER, MYPASS) or error("Error de conexi�n MySQL: ".mysql_error(), true);
mysql_select_db(MYDB, $dbcon) or error("Error de selecci�n BDD: " . mysql_error(), true);

# Obtener lista de vhosts:
$doms = "";
if ($gestor = opendir(DOMS)) {
	while (false !== ($archivo = readdir($gestor))) {
		if ($archivo != "." and $archivo != "..") {
			$doms = $doms.$archivo." ";
		}
	}
	closedir($gestor);
	loguea("Dominios virtuales: ".$doms);
}
else
{
	error("Error leyendo directorio ".DOMS, true);
}

# Obtener lista de tablas:
$resultado = @mysql_query("SHOW TABLES FROM ".MYDB.";", $dbcon)
								or error("Error listando tablas: (SHOW TABLES  FROM ".MYDB.";) ".mysql_error());
if (mysql_num_rows($resultado) == 0)
{
	loguea("No hay ninguna tabla.");
}
else
{
	while ($row = mysql_fetch_row($resultado))
	{
		$tabla = $row[0];
		loguea("+ Tabla ".$tabla);
		# Quitar el "access_" para obtener vhost:
		$vhost = substr($tabla, 7);
		loguea("  - vhost ".$vhost);
		# pasarlo a ereg:
		$vhost = strtr($vhost, "_", ".");
		# �Hay un vhost para esta tabla y no est� en NOLOG?
		if (eregi($vhost, $doms) and !eregi($vhost, NOLOG))
		{
			loguea("    Existe vhost para ".$vhost);
			loguea("    Optimizando tabla ".$tabla);
			@mysql_query("OPTIMIZE TABLE ".MYDB.".".$tabla.";") or error("Error optimizando tabla ".$tabla);
		}
		else
		{
			loguea("    Tabla huerfana. No existe vhost para ".$vhost." o est� marcado como NOLOG.");
			loguea("    Borrando tabla ".$tabla);
			@mysql_query("DROP TABLE ".MYDB.".".$tabla.";") or error("Error borrando tabla ".$tabla);
		}
	}
}

loguea("Fin de proceso.");

# Cerrar BDD:
mysql_close($dbcon);

/* --------------------
   FUNCIONES AUXILIARES
   -------------------- */

# Muestra un error y muere:
function error($texto, $salir = false)
{
	loguea("[ERROR] ".$texto, true);
	if ($salir)
	{
		loguea("Salida forzada por error.");
		die(2);
	}
}

# Escribe en el log:
function loguea($texto, $force_debug = false)
{
	if (DEBUG or $force_debug)
	{
		# Abre fichero de logs:
		$hLog = fopen(LOGFIC, "a");
		fWrite($hLog, "[".date("d-m-Y@h:i:s")."] ".$texto."\n");
		fclose($hLog);
		flush();
	}
	if (ECO)
	{
		echo $texto."\n";
	}
}

# Devuelve el vhost sin www:
function vhost_sin_www($virtualname)
{
	if (eregi("^www\.", $virtualname))
	{
		$fqdn = explode(".", $virtualname, 3);
		Return($fqdn[1].".".$fqdn[2]);
	}
	else
	{
		Return($virtualname);
	}
}

?>
