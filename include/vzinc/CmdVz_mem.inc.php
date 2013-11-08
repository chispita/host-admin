<?php

/* Cambia la memoria asignada a una VE */

$VElist = VZ::GetVEs();

if(empty($VE)) $VE = 999;

$aVEs = VZ::getVEs(CON_NODOS);
Decir("  %b[NUM] En nodo...%n");
$VE = Consola::Array2Menu($aVEs, RET_KEY, $VE, "Entornos virtuales", "VE a modificar");
$nodo = $aVEs[$VE];

// Memoria:
while(true)
{
	decir("%b> INFO%n: Memoria 'barrier'. Se especifica según el sufijo G (Gigas), M (Megas), K (Kilobytes), P (Páginas de 4096b).\n", 0);
	$membarrier = input("¿Memoria asignada?", "128M");
	$memlimit = input("¿Límite de memoria?", "200M");
	if((is_numeric($membarrier) and $membarrier < 16384) or (is_numeric($memlimit) and $memlimit < 16384))
	{
		ERROR::Warn("Creo que está asignando poca memoria. Utilice un sufijo 'G,M,K o P' o asigne más memoria.", CONTINUAR);
	}
	else
	{
		break;
	}
}

Sistema::Ejecuta($nodo, "Asignando memoria", "vzctl set ".$VE." --privvmpages ".$membarrier.":".$memlimit." --save", CRITICO);
Decir("\n%g>%n Finalizado.");
// Info entrar:
Decir("%b[INFO]%n: Recuerde que quizá tenga que reiniciar el VE con 'vz restart ".$VE."'.");

?>
