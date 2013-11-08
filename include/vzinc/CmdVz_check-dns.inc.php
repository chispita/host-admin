<?php

decir("> Comprobando recursión DNS");

$errores = 0;
$aVEs = VZ::getVEs(CON_NODOS);
foreach($aVEs as $container => $nodo)
{
	decir("  - ".$container."...", 0);
	if(VZ::isRunning($container))
	{
		$nNivel = Sistema::ExecLevel(
				$nodo,
				"vzctl exec ".$container." '/usr/local/admin/check_dns_recursor.sh'",
				SILENCIOSO);
		if($nNivel > 0)
		{
			decir("%rERROR%n");
			$errores++;
		}
		else
		{
			decir("%gOK%n");
		}
	}
	else
	{
		decir("%bAPAGADA%n");
	}
}

if($errores > 0)
{
	ERROR::Warn("Se detectaron %r$errores errores%n.", 1);
}
else
{
	decir("%g>%n Todo %gOK%n");
}

?>