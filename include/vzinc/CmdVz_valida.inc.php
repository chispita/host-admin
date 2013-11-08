<?php

// Valida la conf de una máquina virtual:

$nivel = 0;

if(empty($VE))
{
	# No se indica container. Se comprueban todos.
	Decir("%g>%n Validando configuraciones:");
	$aContainers = VZ::getVEs(CON_NODOS);
	foreach($aContainers as $container => $nodo)
	{
		if(!ValidaCfg($container, $nodo))
		{
			$nivel++;
		}
	}
	
	if($nivel > 0)
	{
		Decir("\n%r>%n ERRORES:");
		Decir("  Se han producido ".$nivel." errores.");
		Decir("  Para reparar interactivamente utilice '%yvzcfgvalidate -i <container>%n'.", 2);
		exit($nivel);
	}
}

function ValidaCfg($container, $nodo)
{
	Decir("  %c+%n Container ".$container."...", 0);
	if(Sistema::ExecLevel($nodo, "vzcfgvalidate ".VZCONF_DIR."/".$container.".conf &> /dev/null", SILENCIOSO) == 0)
	{
		Decir("%gOK%n");
		return true;
	}
	else
	{
		Decir("%rFALLO%n");
		$nivel++;
		$aErrores = Sistema::Ejecuta($nodo, "", "vzcfgvalidate ".VZCONF_DIR."/".$container.".conf 2>&1",
				NO_CRITICO, SILENCIOSO, RET_ARRAY);
		foreach($aErrores as $linea)
		{
			Decir("    %r>%n ".$linea);
		}
	}
	return false;
}

?>
