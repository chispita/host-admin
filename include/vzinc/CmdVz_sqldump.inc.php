<?php

/*
 * Hace un volcado de todos los mysql encontrados 
 * todos los VEs de un nodo y los archiva
 * por fechas.
 *
 * Borra los que sean más viejos de una semana o
 * de los días configurados en CADUCIDAD_DIAS.
 *
 */

# Config:
define(TIME, time());                              	 // Unix-timestamp actual.
define(LOGFILE, "/var/log/sqldump.log");           	 // Fichero donde se guardará el último log.
define(CADUCIDAD_DIAS, 15);                        	 // Días en los que caduca un volcado. Será borrado en CADUCIDAD + 1.
define(DUMPDIR, "/backup/remoto/".ESTE_NODO."-sqldump"); // Directorio de volcados.
define(EXCLUDES, "114, 124");			   	 // VEs a excluir del volcado SQL (clientes externos, etc...).

# Cálculos:
$FechaActual       = date("dmY", TIME);
$HoraActual        = date("His", TIME);
$DirVolcado        = DUMPDIR.DIRECTORY_SEPARATOR."sqldump-".$FechaActual."_".$HoraActual; // Dir volcado actual.
$SegundosCaducidad = CADUCIDAD_DIAS * 24 * 60 * 60;
$LimiteCaducidad   = TIME - $SegundosCaducidad;

# Poner aviso "en proceso" para Nagios:
registro("CUR", "EN CURSO.");

# Comprobando que esté montada la unidad de backup:
decir("%g>%n Comprobando unidad de backup...", 0);
if(strpos(file_get_contents("/proc/mounts"), ":/backup/local") === false)
{
	decir("%rERROR%n");
	error("La unidad de backup no está montada.", SALIR);
}
else
{
	decir("%gOK%n");
}

# Vemos que exista el directorio de backups:
decir("%g>%n Comprobando directorio de backup...", 0);
if(!file_exists(DUMPDIR))
{
	decir("%rERROR%n");
	error("No existe directorio de backup: ".DUMPDIR, SALIR);
}
else
{
	decir("%gOK%n");
}

# Borrar los dumps más viejos de una semana.
decir("%g>%n Borrando backups más viejos de ".CADUCIDAD_DIAS." días...");
decir("  Límite de caducidad en %y".date("H:i:s@d/m/Y", $LimiteCaducidad)."%n.");

$aDirs = scandir(DUMPDIR);

foreach($aDirs as $dir)
{
	if($dir == "." or $dir == "..")
	{
		continue;
	}
	decir("  - ".$dir.": ", 0);
	if(is_dir(DUMPDIR.DIRECTORY_SEPARATOR.$dir) and ereg("^sqldump\-([0-9]{8})\_([0-9]{6})$", $dir))
	{
		ereg("^sqldump\-([0-9]{8})\_([0-9]{6})$", $dir, $aCachos);
		$fecha    = $aCachos[1];
		$dia      = substr($fecha, 0, 2);
		$mes      = substr($fecha, 2, 2);
		$año      = substr($fecha, 4, 4);
		$hora     = $aCachos[2];
		$horas    = substr($hora, 0, 2);
		$minutos  = substr($hora, 2, 2);
		$segundos = substr($hora, 4, 2);
		
		# ¿Fecha correcta?
		if(!checkdate($mes, $dia, $año))
		{
			decir("Fecha ".$dia."-".$mes."-".$año." incorrecta.");
		}
		else
		{
			# ¿Es más viejo de CADUCIDAD días?
			$TimeEsteDir = strtotime($año."-".$mes."-".$dia) + ($horas * 60 * 60) + ($minutos * 60) + $segundos;
			if($TimeEsteDir < $LimiteCaducidad)
			{
				decir("Caducado...Borrando.");
				if(!Sistema::BorraRecDir(DUMPDIR.DIRECTORY_SEPARATOR.$dir))
				{
					error("borrando $dir.", CONTINUAR);
				}
			}
			else
			{
				decir("Mantener.");
			}
		}
	}
	else
	{
		decir("Desconocido.");
	}
}

# Crear un directorio para este volcado:
decir("%g>%n Creando directorio de volcado (".$DirVolcado.")...");
mkdir($DirVolcado, 0700) or error("Creando dir.", SALIR);

if(!empty($VE))
{
	# Se especifica un VE.
	# Sólo se volcará ese VE.
	$aVEs = array($VE);
	decir("%g>%n Volcar sólo VE ".$aVEs[0]."...");
}
else
{
	# Listar VEs de este nodo:
	decir("> Listando containers...", 0);
	exec(CMD_VZLIST." --all --no-header --output veid|tr -d ' '", $aVEs, $nivel);
	if($nivel > 0)
	{
		error("Listando VEs.", SALIR);
	}
	elseif(empty($aVEs))
	{
		error("¿No hay containers?", SALIR);
	}
	else
	{
		foreach($aVEs as $VeId)
		{
			decir($VeId." ", 0);
		}
	}
}	

decir("%y<EOF>%n");

# Volcar cada mysql si existe en el VE:
decir("%g>%n Volcando containers:");
foreach($aVEs as $VeId)
{
	decir("  - %c".$VeId."%n...", 0);
	$aExcludes = split("\,|\,\ ", EXCLUDES);
	
	if(array_search($VeId, $aExcludes) !== false)
	{
		decir("%yExcluida%n.");
	}
	else
	{
		// Detectar MySQL:
		unset($aSalida);
		exec(CMD_VZCTL." exec ".$VeId." pidof mysqld", $aSalida, $nivel);
		if($nivel != 0)
		{
			decir("%ymysqld no detectado%n.");
		}
		else
		{
			decir("mysqld %gOK%n, volcando:");
			mkdir($DirVolcado."/".$VeId);
			# Obtener bases de datos:
			unset($aDBs);
			exec("echo 'show databases;' | ".CMD_VZCTL." exec ".$VeId." mysql --silent", $aDBs, $nivel);
			if($nivel != 0)
			{
				error("Consultando lista DBs en VE ".$VeId, CONTINUAR);
			}
			else
			{
				# Volcar cada DB:
				foreach($aDBs as $db)
				{
					decir("    - ".$db."...", 0);
					exec(CMD_VZCTL." exec ".$VeId." mysqldump --lock-all-tables ".$db
						." |gzip > ".$DirVolcado."/".$VeId."/".$db.".sql.gz");
					if($nivel != 0)
					{
						error("Volcando DB ".$db." de VE ".$VeId);
					}
					else
					{
						decir("%gOK%n");
					}
				}
			}
		}
	}
}

# Salir:
salir(0);

# Funciones:
function salir($nivel = 0)
{
	global $aErrores;
	
	decir("\nFinalizado.");
	if(!empty($aErrores))
	{
		foreach($aErrores as $errortxt)
		{
			$errorlog .= "  - ".$errortxt."\n";
			decir("  %r-%n ".$errortxt);
		}
		registro("FALLO", "FINALIZADO CON ERRORES:\n".$errorlog);
		if($nivel < 1) $nivel = 1;
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
	
	decir("%rERROR%n: ".$error);
	$aErrores[] = $error;
	if($salir)
	{
		foreach($aErrores as $errortxt)
		{
			$errorlog .= "  - ".$errortxt."\n";
		}
		registro("FALLO", "ABORTADO POR ERROR CRÍTICO:\n".$errorlog);
		exit(1);
	}
	return $aErrores;
}

function registro($estado = "OK", $texto)
{
		file_put_contents(LOGFILE, "[".time().":".$estado."] ".date("H:i:s@d-m-Y", time())." ".$texto."\n");
}

?>