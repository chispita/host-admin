<?php

// Listado de máquinas virtuales:
decir("%cLista de máquinas virtuales%n:", 2);
decir("+ %gDisponibles%n:");
decir(VZ::ListVEsDesc("nodos"));

decir("%3%K ".VZ::CountVEs()." %n máquinas virtuales disponibles.", 2);
#decir("+ %gCorriendo en este nodo%n:");
#decir(VZ::RunningVEs(), 2);

?>
