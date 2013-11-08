<?php

decir("Debug:");

decir("getVes:");
$aVEs = VZ::getVEs();
print_r($aVEs);

decir("getVes:CON_NODOS:");
$aVEs = VZ::getVEs(CON_NODOS);
print_r($aVEs);

decir("Running:");
decir(VZ::RunningVEs());

?>