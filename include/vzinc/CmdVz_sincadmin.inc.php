<?php

/*
 * Sincroniza los scripts de administración del nodo maestro al resto de los nodos.
 */
 
$aNodos = VZ::getNodos();
array_shift($aNodos);

Decir("%b> INFO%n: Se sincronizarán los scripts de administración desde %c".OVZ_MASTER_NODE."%n hacia:");
foreach($aNodos as $key => $nodo)
{
	Decir("        - %c".$nodo."%n", 1);
}

if(Consola::SioNo("¿Desea sincronizar?"))
{
	Decir("%g>%n Anulando Cachés:");
	Cache::DelAll();
	Decir("%g>%n Sincronizando scripts:");
	foreach($aNodos as $key => $nodo)
	{
		Sistema::Ejecuta(OVZ_MASTER_NODE, "   Sincronizando %c".$nodo."%n",
					"rsync -axE --recursive --no-relative --delete --exclude=hostname.banner ".ADMIN_DIR."/ root@".$nodo.":".ADMIN_DIR."/",
					CRITICO);
	}
	Decir("%g>%n Sincronización finalizada.");
}
else
{
	ERROR::Warn("Sicronización abortada.", CONTINUAR);
}

 

?>