<?php

if(empty($VE)) $VE="#ID";

Decir("%b[INFO]%n: Para entrar en una VE utilice una de estas tres formas:", 2);
Decir("\t%g-%n vze ".$VE);
Decir("\t%g-%n vzctl enter ".$VE);
Decir("\t%g-%n ssh ip_local", 2);

?>
