<?php

/* Clase para cálculo de IPs */

Class Cidr
{
	/* Devuelve la IP correspondiente a un determinado VE */
	static public function getIpForId($VeId)
	{
		list($ConfIp, $ConfBits) = explode('/', RANGO_IP_VES);
		list($a, $b, $c, $d) = explode('.', $ConfIp);
		$CidrIp = ($a << 24) + ($b << 16) + ($c << 8) + $d;
		$CidrMask = $ConfBits == 0 ? 0 : (~0 << (32 - $ConfBits));
		$CidrNetId = $CidrIp & $CidrMask;
		$CidrBroadcast = $CidrIp | (~$CidrMask & 0xFFFFFFFF);

		//DEBUG:
		#decir("RANGO_IP_VES: ".RANGO_IP_VES);
		#decir("CIDR: ".$CidrIp."/".$CidrMask);
		#decir("Inicio: ".long2ip($CidrNetId + 1));
		#decir("Fin: ".long2ip($CidrBroadcast - 1));
		#decir("NºHosts: ".($CidrBroadcast - $CidrIp));

		// La IP es el id de red + el ID del VE -100:
		$VeIp = long2ip($CidrNetId + $VeId - 100);
		return $VeIp;
	}

	/* Devuelve el mayor número posible para una VE
	 * Dependiendo de IP/MASK de la configuración:
	 */
	static public function getMaxHosts()
	{
		list($ConfIp, $ConfBits) = explode('/', RANGO_IP_VES);
                list($a, $b, $c, $d) = explode('.', $ConfIp);
                $CidrIp = ($a << 24) + ($b << 16) + ($c << 8) + $d;
                $CidrMask = $ConfBits == 0 ? 0 : (~0 << (32 - $ConfBits));
                $CidrNetId = $CidrIp & $CidrMask;
		$CidrBroadcast = $CidrIp | (~$CidrMask & 0xFFFFFFFF);

		//DEBUG:
		#decir("RANGO_IP_VES: ".RANGO_IP_VES);
		#decir("CIDR: ".$CidrIp."/".$CidrMask);
		#decir("Inicio: ".long2ip($CidrNetId + 1));
		#decir("Fin: ".long2ip($CidrBroadcast - 1));
		#decir("NºHosts: ".($CidrBroadcast - $CidrIp));

		return($CidrBroadcast - $CidrIp);
	}
}
?>
