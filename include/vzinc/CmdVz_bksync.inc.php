<?php

/*
 * Sincroniza una copia de todos los containers
 * en una máquina remota o directorio local.
 *
 */

# Includes:
require("/usr/local/admin/include/vzinc/config.inc.php");

# Comprobar si tiene par de backup:
if(!defined(PAR_BACKUP))
{
	error(ESTE_NODO." no tiene par de backup definido.", SALIR);
}

# Config:
define(TIME, time()); // Unix-timestamp actual.
define(LOGFILE, "/var/log/vzbksync.log"); // Fichero donde se guardará el último log.
define(DST_HOST, PAR_BACKUP);
define(DST_DIR, "/backup/local/".ESTE_NODO."-vzbksync");
define(DESTINO, "root@".DST_HOST.":".DST_DIR."/."); // Destino del volcado.
define(RSYNC_OPTS, "-aXdzq"); // Opciones para rsync.

# Poner aviso "en proceso" para Nagios:
if(!empty($VE))
{
	registro("CUR", "EN CURSO (container ".$VE.").");
}
else
{
	registro("CUR", "EN CURSO (todos).");
}

# Cálculos:
$FechaActual       = date("dmY", TIME);
$HoraActual        = date("His", TIME);

decir("%g>%n Sincronizar backups ".ESTE_NODO." --> ".PAR_BACKUP);
decir("> Destino: ".DESTINO);
Decir("%g>%n Borrando cache...");
Cache::DelAll();
Sistema::Ejecuta(PAR_BACKUP, "Creando dir de destino", "mkdir -p ".DST_DIR, CRITICO);

$aContainers = VZ::GetVEs(SIN_NODOS, LOCAL);

if(empty($aContainers))
{
	error("No hay contenedores en este host.", SALIR);
}

if(!empty($VE))
{
	if(array_search($VE, $aContainers) !== false)
	{
		decir("%y>%n Volcar sólo container ".$VE.".");
		unset($aContainers);
		$aContainers = array($VE);
	}
	else
	{
		error("No existe el container ".$VE.".", SALIR);
	}
}
else
{
	decir("%y>%n Volcar todos los containers.");
}

# Volcar cada VE:
foreach($aContainers as $VeId)
{
	decir("%g>%n Volcando container ".$VeId.":");
	$inicio = time();
	decir("\t%c+%n ".$VeId.": sync en caliente...", 0);
	exec("rsync ".RSYNC_OPTS." ".VEDIR."/".$VeId." ".DESTINO." &> /dev/null", $aSalida, $nivel);
	if($nivel != 0 and $nivel !=24)
	{
		decir("%rFALLO%n");
		error("(".$nivel.") volcando VE ".$VeId.".\n", CONTINUAR);
	}
	else
	{
		decir("%gOK%n.");
		if(VZ::isRunning($VeId))
		{
			decir("\t", 0);
			VZ::Stop($VeId);
			decir("\t%c+%n ".$VeId.": resincronizando en parado...", 0);
			exec("rsync ".RSYNC_OPTS." ".VEDIR."/".$VeId." ".DESTINO, $aSalida, $nivel);
			if($nivel != 0)
			{
				decir("%rFALLO%n");
				error("(".$nivel.") volcando VE ".$VeId.".\n", CONTINUAR);
			}
			decir("%gOK%n.");
			decir("\t", 0);
			VZ::Start($VeId);
		}
		else
		{
			decir("\t%b-%n Apagada. No es necesario resync.");
		}
	}
	decir("\t%b>%n Sincronizado en %c".Fecha::hace($inicio)."%n.");
}

decir("%b>%n Backup completo en ".Fecha::hace(TIME).".");

# Salir:
salir(0);

# Funciones:
function salir($nivel)
{
	global $aErrores;
	
	echo "\nFinalizado.\n";
	if(!empty($aErrores))
	{
		print_r($aErrores);
		registro("FALLO", "FINALIZADO CON ERRORES:\n".print_r($aErrores, true));
	}
	else
	{
		# Finalizado correctamente:
		registro("OK", "FINALIZADO OK.");
	}
	exit($nivel);
}

function error($error, $salir=false)
{
	global $aErrores;
	
	echo "ERROR: ".$error."\n";
	$aErrores[] = $error;
	if($salir)
	{
		registro("FALLO", "ABORTADO POR ERROR CRÍTICO:\n".print_r($aErrores, true));
		exit(255);
	}
	return $aErrores;
}

function registro($estado = "OK", $texto)
{
		file_put_contents(LOGFILE, "[".time().":".$estado."] ".date("H:i:s@d-m-Y", time())." ".$texto."\n");
}

?>
