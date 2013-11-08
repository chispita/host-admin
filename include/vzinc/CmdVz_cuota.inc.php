<?php

/* Cambia la cuota de disco asignada a una VE */
# vzctl set 104 --diskspace 4194304:5242880 --save
# vzquota setlimit 104 -b 4194304 -B 5242880

$VElist = VZ::GetVEs();

if(empty($VE)) $VE = 999;

$aVEs = VZ::getVEs(CON_NODOS);
Decir("  %b[NUM] En nodo...%n");
$VE = Consola::Array2Menu($aVEs, RET_KEY, $VE, "Entornos virtuales", "VE a modificar");
$nodo = $aVEs[$VE];

// Memoria:
while(true)
{
	decir("%b> INFO%n: Disco asignado. Se especifica según el sufijo G (Gigas), M (Megas), K (Kilobytes), P (Páginas de 4096b).\n", 0);
	$disk = input("¿Disco asignado?", "2G");
	$disklimit = input("¿Límite de disco?",  "3G");
	if((is_numeric($disk) and $disk < 16384) or (is_numeric($disklimit) and $disklimit < 16384))
	{
		ERROR::Warn("Creo que está asignando poco disco. Utilice un sufijo 'G,M,K o P' o asigne más disco.", CONTINUAR);
	}
	else
	{
		break;
	}
}

Sistema::Ejecuta($nodo, "Asignando disco", "vzctl set ".$VE." --diskspace ".$disk.":".$disklimit." --save", CRITICO);
Decir("\n%g>%n Finalizado.");

?>
