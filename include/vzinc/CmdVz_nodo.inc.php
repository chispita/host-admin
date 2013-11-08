<?php

// Busca un VE y dice en que nodo físico está:

decir("Buscando VE ".$VE."...", 0);
$nodo = VZ::queNodo($VE);
decir($nodo);

?>