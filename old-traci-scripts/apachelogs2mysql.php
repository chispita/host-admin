#!/usr/bin/php -q
<?php

# ---------------------------------------------------------------------
# apachelogs2mysql.php
#
# Obtiene logs de Apache por la entrada estandar:
#
# | RUTA_PROGRAMA <tipo de log>
# (CustomLog "|/usr/local/admin/apachelogs2mysql.php access" common)
# (El tipo de log puede ser access o error.
#
# Y los inserta en tablas mysql, creándolas al vuelo.
#
# queru@queru.org - Enero 2006.
# ---------------------------------------------------------------------

# Quitar errores en html:
ini_set("html_errors", false);
# Que no se detenga la ejecución por tiempo:
set_time_limit(0);

# Configuraci�n:
# ---------------------------------------------------------------------
define("LOGFIC", "/var/log/apache2/apachelogs2mysql.log");
define("DEBUG", true);
define("MYHOST", "localhost");
define("MYUSER", "httpdlogger");
define("MYPASS", "h77pd_l0gg3r");
define("MYDB", "cqtraci_logs");
# Localicación de las carpetas web de los vhosts dinámicos:
define("DOMS", "/web/domains");
# Los que estén en NOLOG son descartados:
define("NOLOG", "pumbo.com, 3djuegos.com, solodemos.com, demoindex.com");
# ---------------------------------------------------------------------
# FIN de config.

loguea("Inicio de proceso.");
if (DEBUG)
{
	loguea("Debug ACTIVADO.");
}
else
{
	loguea("Debug desactivado.");
}

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

# Conexión con BDD:
$dbcon = @mysql_connect(MYHOST, MYUSER, MYPASS) or error("Error de conexi�n MySQL: ".mysql_error(), true);
mysql_select_db(MYDB, $dbcon) or error("Error de selecci�n BDD: " . mysql_error(), true);

$handle = fopen("php://stdin", "r");
while (!feof($handle))
{
	$buffer = fgets($handle, 2048);
	if ($buffer != false)
	{
		# id|virtualname|host|time|methodurl|code|bytesd|referer|user-agent
		if (substr_count($buffer, "|") < 7)
		{
            error("Entrada de log inv�lida: {\n".$buffer."\n}");
			$buffer = fgets($handle, 2048);
		}
		else
		{
			list($id, $virtualname, $host, $time, $methodurl, $code, $bytesd, $referer, $useragent) = explode("|", $buffer, 9);
			# vhost-ereg:
			$vhost = strtr($virtualname, "-_", "..");
			# Quita las www:
			$virtualname = vhost_sin_www($virtualname);
			# Comprueba si hay que loguearlo o no.
			if (strpos(NOLOG, $virtualname) === false and eregi("\ ".$virtualname."\ ", $doms))
			{
				# Escupe todo al log si hay DEBUG:
				if (DEBUG)
				{
					loguea("Recibido log {\n"
							."  Crudo.......: ".$buffer."\n"
							."  id..........: ".$id."\n"
							."  Virtualname.: ".$virtualname."\n"
							."  Host........: ".$host."\n"
							."  Time........: ".$time."\n"
							."  Methodurl...: ".$methodurl."\n"
							."  Code........: ".$code."\n"
							."  Bytesd......: ".$bytesd."\n"
							."  Referer.....: ".$referer."\n"
							."  Useragent...: ".$useragent."\n"
							."}\n");
				}
		
				# Comprueba si existe la tabla:
				$tablename = "access_".strtr($virtualname, ".-", "__");
				loguea("Comprobando si existe tabla ".$tablename);
				$resultado = @mysql_query("SHOW TABLES LIKE '".$tablename."';", $dbcon)
								or error("Error listando tablas: (SHOW TABLES LIKE 'access_".$tablename."';) ".mysql_error());
				if (mysql_num_rows($resultado) == 0)
				{
					loguea("No existe la tabla ".$tablename);
					$query =	"CREATE TABLE ".$tablename." ( \n"
									."id VARCHAR( 24 ) NOT NULL, \n"
									."ip_cliente VARCHAR( 15 ) NOT NULL, \n"
									."timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, \n"
									."time VARCHAR( 28 ) NOT NULL, \n" 
									."url VARCHAR( 500 ) NOT NULL, \n"
									."codigo TINYINT NULL, \n"
									."bytesd BIGINT NULL, \n"
									."referer VARCHAR( 500 ) NULL, \n"
									."useragent VARCHAR( 255 ) NULL\n"
									.") TYPE = ARCHIVE CHARACTER SET latin1 COLLATE latin1_spanish_ci \n"
									."COMMENT = 'Access.log de viernes.org';";
					@mysql_query($query) or error("Error creando tabla ".$tablename.": ".mysql_error(), true);
					loguea("Creada ".$tablename);
				}
				else
				{
					loguea("Ya existe tabla ".$tablename);
				}
				# Inserta el log en su tabla:
				$query = "INSERT INTO ".$tablename." (id, ip_cliente, time, url, codigo, bytesd, referer, useragent) "
							."VALUES ('".$id."', '".$host."', '".$time."', '".$methodurl."', '".$code."', '".$bytesd."', "
										."'".$referer."', '".$useragent."');";
				loguea($query);
				@mysql_query($query) or error("Error insertando registro en ".$tablename.": "
												.mysql_error()
												."\nQuery: ".$query);								
			}
			else
			{
				# No hay que loguear este dominio:
				loguea("Log para ".$virtualname." desactivado o el vhost no existe.");
			}
		}
	}
}


loguea("Fin de proceso: No hay más logs.");

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
