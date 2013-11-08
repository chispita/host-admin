<?php

// Edita la conf de una máquina virtual:

if(empty($VE))
{
	ERROR::Warn("Indique número de container.");
}

if(VZ::ExisteVE($VE))
{
	$aVEs = VZ::getVEs(CON_NODOS);
	$nodo = $aVEs[$VE];
	
	# Abrir ficheros temporales:
	$TmpFile = tempnam(TMPDIR, "vzconf-");
	$fTmp = fopen($TmpFile, w);
	
	# Pillar la conf y grabarla en el temporal:
	Decir("%g>%n Editar container ".$VE." de ".$nodo.":");
	$aConf = Sistema::Ejecuta($nodo, "Capturando conf", "cat ".VZCONF_DIR."/".$VE.".conf", CRITICO, RUIDOSO, RET_ARRAY);
	Decir("%g>%n Traspasando a temporal...", 0);
	foreach($aConf as $num => $linea)
	{
		$aConf[$num] = $aConf[$num]."\n";
		fwrite($fTmp, $linea."\n");
	}
	fclose($fTmp);
	Decir(count($aConf)." lineas %gOK%n");
	
	# Abrir editor:
	Decir("%g>%n Abriendo %yvim%n...");
	passthru("vi ".$TmpFile);
	Decir("%g>%n Edición finalizada.");
	
	# Comprobar si hay cambios:
	$aConfEdited = file($TmpFile);
	$aDiff = array_diff($aConfEdited, $aConf);
	if(empty($aDiff))
	{
		Decir("%r>%n No hay cambios en la configuración.");
	}
	else
	{
		Decir("%y>%n ".count($aDiff)." cambio".(count($aDiff) > 1 ? "s" : "")." en la configuración.");
		Sistema::Ejecuta(ESTE_NODO, "Copiando a ".$nodo, "scp ".$TmpFile." root@".$nodo.":".VZCONF_DIR."/".$VE.".conf");
	}
	# Borrar temporal:
	unlink($TmpFile);
}
else
{
	ERROR::Warn("No existe el container ".$VE);
}

?>
