<?php

/*
 * (c)2008 Jorge Fuertes
 * queru@queru.org
 *
 */

/* Comprueba que todas las máquinas virtuales estén resolviendo bien. */

$ErroresVEs = 0;
$ErroresNodos = 0;
$ErroresServers = 0;

# Comprobar si nuestros servidores de DNS funcionan:
$aServers = split("\,|\,\ ", DNSAUTH);
foreach($aServers as $server)
{
	if(!Sistema::Ejecuta(ESTE_NODO, "Comprobando DNS autoritativo ".$server, "dig @".$server." srv1.ibercivis.es &> /dev/null",
				NO_CRITICO, SILENCIOSO, SIN_SALIDA))
	{
		$ErroresServers++;
	}
}

# Ver si resuelven todos los nodos:
Decir("%b[NODOS:]%n");
$aNodos = VZ::getNodos();
foreach($aNodos as $nodo)
{
	if(!Sistema::Ejecuta($nodo, "Comprobando resolución de nodo ".$nodo, "dig srv1.ibercivis.es &> /dev/null", NO_CRITICO, SILENCIOSO, SIN_SALIDA))
	{
		$ErroresNodos++;
	}
}

Decir("%b[Entornos VE:]%n");
$aVEs = VZ::getVEs(CON_NODOS);
foreach($aVEs as $veid => $nodo)
{
	# Comprobamos si está UP:
	if(VZ::isRunning($veid, $nodo))
	{
		# Si no tiene el comando 'host' se lo instalamos:
		if(Sistema::Ejecuta($nodo, "", "vzctl exec ".$veid." ls /usr/bin/host &> /dev/null",
					NO_CRITICO, SIENCIOSO, SIN_SALIDA) == false)
		{
			Sistema::Ejecuta($nodo, "Instalando 'host' en VE ".$veid,
					"vzctl exec ".$veid." apt-get -y install host &> /dev/null",
					NO_CRITICO, RUIDOSO, SIN_SALIDA);
		}
	
		#Ejecuta($nodo = HOST_FQDN, $desc, $cmd, $critico = true, $silencioso = false, $retarray = false)
		if(Sistema::Ejecuta(
					$nodo,
					"Probando DNS de VE ".$veid,
					"vzctl exec ".$veid." host google.es",
					NO_CRITICO,
					SILENCIOSO,
					SIN_SALIDA
			) == false)
		{
			$ErroresVEs++;
		}
	}
	else
	{
		Decir("%g>%n Probando DNS de VE ".$veid."...%yPARADA%n.");
	}
}

Decir("%b[RESULTADO:]%n");

if($ErroresServers > 0)
{
	ERROR::Warn("Algún (".$ErroresServers.") servidor DNS autoritativo puede estar fallando.", CONTINUAR);
}
else
{
	Decir("%g+%n Los servidores autoritativos funcionan bien.");
}

if($ErroresNodos > 0)
{
	ERROR::Warn("En algún (".$ErroresNodos.") NODO el DNS puede estar fallando.", CONTINUAR);
}
else
{
	Decir("%g+%n Todos los nodos resuelven correctamente.");
}

if($ErroresVEs > 0)
{
	ERROR::Warn("En algún (".$ErroresVEs.") VE el DNS puede estar fallando.", CONTINUAR);
}
else
{
	Decir("%g+%n Todos los VEs que están UP resuelven correctamente.");
}

$errores = $ErroresNodos + $ErroresVEs + $ErroresServers;
if($errores > 0)
{
	ERROR::Warn("Hay ".$errores." errores críticos. Se precisa intervención.", SALIR, 69);
}
else
{
	Decir("%g+%n Finalizado correctamente.");
}

?>
