<?php

/*
 * (c)2008 Jorge Fuertes
 * queru@queru.org
 *
 * Para llamar desde Nagios. Comprueba el resultado de una operación de volcado.
 * Estas operaciones dejan un LOG de resultado en /var/log.
 */

if(empty($OPC) or !eregi("^vzdump|vzbksync|sqldump$", $OPC))
{
	decir("Utilización: vz check-last-operation <vzdump|vzbksync|sqldump>");
	exit(1);
}

$ToCheck = "/var/log/".strtolower($OPC).".log";

# Comprobando estado correspondiente:
# Cargamos fichero de log:
$log = trim(file_get_contents($ToCheck));
# Extraer timestamp y resultado:
ereg("^\[([0-9]*)\:(.*)\]", $log, $aRegs);
$timestamp = $aRegs[1];
$resultado = $aRegs[2];

if(empty($timestamp) or empty($resultado) or !ereg("OK|CUR|FALLO", $resultado))
{
	decir("ERROR de parsing de log.");
	exit(1);
}

if($resultado == "OK")
{
	# El timestamp no puede ser más viejo de 24h:
	if($timestamp < (time() - (48 * 60 * 60)))
	{
		decir("ERROR: Esta en OK hace más de 48h, desde ".date("H:i:s@d-m-Y", $timestamp).".");
		exit(1);
	}
	else
	{
		decir($log);
		exit(0);
	}
}
else if($resultado == "CUR")
{
	# El timestamp no puede ser más viejo de 4h:
	if($timestamp < (time() - (6 * 60 * 60)))
	{
		decir("ERROR: Esta EN CURSO hace mas de 6h, desde ".date("H:i:s@d-m-Y", $timestamp).".");
		exit(1);
	}
	else
	{
		decir($log);
		exit(0);
	}	
}
else
{
	decir($log);
	exit(1);
}

?>