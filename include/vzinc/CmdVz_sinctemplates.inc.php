<?php

/*
 * Sincroniza los templates del nodo físico 0 al resto de los nodos.
 */
 
$aNodos = VZ::getNodos();
array_shift($aNodos);

Decir("%b> INFO%n: Se sincronizarán los templates desde %c".OVZ_MASTER_NODE."%n hacia:");
foreach($aNodos as $key => $nodo)
{
	Decir("        - %c".$nodo."%n", 1);
}

if(Consola::SioNo("¿Desea sincronizar?"))
{
	Decir("%g>%n Sincronizando templates:");
	foreach($aNodos as $key => $nodo)
	{
		Sistema::Ejecuta(OVZ_MASTER_NODE, "   Sincronizando %c".$nodo."%n",
					"rsync -axE --recursive --no-relative --delete ".TEMPLATE_DIR."/ root@".$nodo.":".TEMPLATE_DIR."/",
					CRITICO);
	}
	Decir("%g>%n Sincronización finalizada.");
}
else
{
	ERROR::Warn("Sicronización abortada.", CONTINUAR);
}

 

?>