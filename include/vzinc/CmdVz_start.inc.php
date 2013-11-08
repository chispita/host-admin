<?php

if(empty($VE))
{
	$aVEs = VZ::getVEs(CON_NODOS);
	Decir("  %b[NUM] En nodo...%n");
	$VE = Consola::Array2Menu($aVEs, RET_KEY, 999, "Entornos virtuales", "VE que desea iniciar");
	$nodo = $aVEs[$VE];
}

VZ::Start($VE);

?>