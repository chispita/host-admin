<?php

// Borra una máquina virtual:

if(VZ::CountVEs() == 0)
{
	ERROR::Warn("No hay VEs que borrar.", SALIR);
}

if(empty($VE)) $VE = 999;

$aVEs = VZ::getVEs(CON_NODOS);
Decir("  %b[NUM] En nodo...%n");
$borrarVE = Consola::Array2Menu($aVEs, RET_KEY, $VE, "Entornos virtuales", "VE que desea borrar");
$nodo = $aVEs[$borrarVE];

if(Consola::SioNo("¿Seguro que desea borrar la VE %r".$borrarVE."%n de %c".$nodo."%n?"))
{
	// Borrar máquina virtual:
	Sistema::Ejecuta($nodo, "Parando VE", "vzctl stop ".$borrarVE."  &> /dev/null", NO_CRITICO);
	Sistema::Ejecuta($nodo, "Destruyendo VE", "vzctl destroy ".$borrarVE, NO_CRITICO);
	Sistema::Ejecuta($nodo, "Borrando conf vieja", "rm /etc/vz/conf/".$borrarVE.".conf.destroyed", NO_CRITICO);
	// Anulamos el caché:
	Cache::DelAll();
	Decir("%g>%n Finalizado.");
}
else
{
	Decir("%r>%n Cancelado.");
}

?>
