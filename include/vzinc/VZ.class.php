<?php

  /*
   * Clase VZ: Métodos relacionados con OpenVZ.
   * queru@queru.org
   * Wed Dec 26 12:39:48 CET 2007
   */

class VZ
{
	/*
	 * Array con los nodos del cluster OpenVZ.
	 */
	 public static function getNodos()
	 {
		$aNodos = split("\,|\,\ ", OVZ_NODES);
		return $aNodos;
	 }
	 
	 /*
	  * ¿En que nodo está un VE?
	  */
	  public static function queNodo($VeId)
	  {
		// Primero mirar si está en el nodo local:
		$aVEs = VZ::getVes(false, true);
		if(array_search($VeId, $aVEs) !== false)
		{
			return ESTE_NODO;
		}
		else
		{
			// Miramos en todos los nodos.
			$aVEs = VZ::getVes(CON_NODOS);
			if(!empty($aVEs[$VeId]))
			{
				return $aVEs[$VeId];
			}
		}
		decir("No existe el VE ".$VeId);
		return false;
	  }
	 	 
	/*
	* Obtiene una lista de máquinas virtuales diponibles,
	* estén arrancadas o no.
	*/
	//- mark GetVEs
	static public function getVEs($ConNodos = false, $SoloLocal = false)
	{
		# Primero creamos los cachés de no existir:
		# VEs locales:
		if(Cache::Exists("aVEsLocales"))
		{
			$aVEsLocales = Cache::Get("aVEsLocales");
		}
		else
		{
			$aVEsLocales = Sistema::Ejecuta(ESTE_NODO, "", "ls -C1 ".VEDIR, NO_CRITICO, SILENCIOSO, RET_ARRAY);
			sort($aVEsLocales, SORT_NUMERIC);
			# Escribimos el caché:
			Cache::Put("aVEsLocales", $aVEsLocales);
		}
		
		# VEs con nodos:
		if(Cache::Exists("aVEsConNodos"))
		{
			$aVEsConNodos = Cache::Get("aVEsConNodos");
		}
		else
		{
			// Nodos del cluster:
			$aNodos = VZ::getNodos();
			// Máquinas de cada nodo:
			$aVEsConNodos = array();
			foreach($aNodos as $nodo)
			{
				$aVEsTmp = Sistema::Ejecuta($nodo, "", "ls -C1 ".VEDIR, NO_CRITICO, SILENCIOSO, RET_ARRAY);
	
				if(empty($aVEsTmp))
				{
					#ERROR::Warn("No hay VEs en ".$nodo.".", CONTINUAR);
				}
				else
				{
					foreach($aVEsTmp as $VeId)
					{
						$aVEsConNodos[$VeId] = $nodo;
						ksort($aVEsConNodos, SORT_NUMERIC);
					}
				}
			}
			Cache::Put("aVEsConNodos", $aVEsConNodos);
		}  	  	
	
		# VEs sin nodos:
		if(Cache::Exists("aVEsSinNodos"))
		{
			$aVEsSinNodos = Cache::Get("aVEsSinNodos");
		}
		else
		{
			// Nodos del cluster:
			$aNodos = VZ::getNodos();
			// Máquinas de cada nodo:
			$aVEsSinNodos = array();
			foreach($aNodos as $nodo)
			{
				$aVEsTmp = Sistema::Ejecuta($nodo, "", "ls -C1 ".VEDIR, NO_CRITICO, SILENCIOSO, RET_ARRAY);
	
				if(empty($aVEsTmp))
				{
					ERROR::Warn("No hay VEs en ".$nodo.".", CONTINUAR);
				}
				else
				{
					$aVEsSinNodos = array_merge($aVEsSinNodos, $aVEsTmp);
					sort($aVEsSinNodos, SORT_NUMERIC);
				}
			}
			Cache::Put("aVEsSinNodos", $aVEsSinNodos);
		}  	  	
	
		# Devolver lo que se esté pidiendo:
		if($SoloLocal)
		{
			$aVEs = $aVEsLocales;
		}
		else
		{
			if($ConNodos)
			{
				$aVEs = $aVEsConNodos;
			}
			else
			{
				$aVEs = $aVEsSinNodos;
			}
		}
	
		if(empty($aVEs))
		{
			ERROR::Warn("No hay VEs.", CONTINUAR);
			return false;
		}
		else
		{
			return $aVEs;
		}
	}
	
	/*
	* Devuelve un listado de máquinas disponibles.
	* Delimitado por por ", ".
	*/
	static public function ListVEs()
	{
		$VEs = VZ::GetVEs();
		$listado = "";
		foreach($VEs as $VE)
		{
			if(!empty($listado)) $listado .= ", ";
			$listado .= $VE;
		}
		return $listado.".";
	}
	
	/*
	* Devuelve un listado de máquinas disponibles.
	* Con descripciones, una por línea.
	* @param $orden Si hay que ordenar por id o por nodos.
	*/
	static public function ListVEsDesc($orden = "id")
	{
		$VEs = VZ::GetVEs(CON_NODOS);
		if($orden = "nodos") asort($VEs);
	
		$listado = "  %4%w".str_pad("ID:", 5).str_pad("HOSTNAME:", 25).str_pad("NODO:", 25).str_pad("ESTADO:", 8)."%n\n";
		$lastnodo = "ninguno";
		foreach($VEs as $VeId => $nodo)
		{
			if($lastnodo != $nodo)
			{
				$listado .= "  %b".$nodo.":%n\n";
				$lastnodo = $nodo;
			}
			Consola::DiAtras("%r>%n Consultando %y$nodo%n...");
			$hostname = Sistema::Ejecuta($nodo, "", "cat ".VEDIR."/".$VeId."/etc/hostname", NO_CRITICO, SILENCIOSO, RET_VALUE);
			$nNivel   = Sistema::Ejecuta($nodo, "", "vzlist -a|grep -e $VeId.*stopped", NO_CRITICO, SILENCIOSO);
			if($nNivel != 0)
			{
				$estado = "%rDOWN%n";
			}
			else
			{
				$estado = "%gUP%n";
			}
			$listado .= "  ".str_pad($VeId, 5).str_pad($hostname[0], 25).str_pad($nodo, 25).$estado."\n";
		}
		Consola::BorraLinea();
		return $listado;
	}
	
	/* Número de máquinas virtuales presentes en el sistema */
	static public function CountVEs()
	{
		return count(VZ::GetVEs());
	}
	
	# Devuelve true si una VE está corriendo y false si no:
	public static function isRunning($veid, $nodo = "")
	{
		if(empty($nodo))
		{
			$nodo = VZ::queNodo($veid);
		}
		
		if(Sistema::Ejecuta($nodo, "", "vzlist |grep ".$veid, NO_CRITICO, SILENCIOSO))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/* Listado de las máquinas que están corriendo */
	static public function RunningVEs()
	{
		exec("vzlist", $aLista);
		foreach($aLista as $linea)
		{
			$lista .= $linea."\n";
		}
		return $lista;
	}
	
	/* Determina si existe una VE: */
	static public function ExisteVE($nVE)
	{
		$aVEs = VZ::GetVEs();
		if(array_search($nVE, $aVEs) === false)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	
	/* Destruir una VE completamente: */
	static public function DestroyVE($nVE)
	{
		VZ::Stop($VE);
		system("vzctl destroy ".$nVE);
		system("rm /etc/vz/conf/".$nVE.".conf.destroyed");
	}
	
	/* Arranque de una VE */
	static public function Start($VE)
	{
		if(VZ::ExisteVE($VE))
		{
			Sistema::Ejecuta(VZ::QueNodo($VE), "Arrancando container ".$VE, "vzctl start ".$VE." &> /dev/null");
		}
		else
		{
			ERROR::Warn("No existe el container ".$VE.".", SALIR);
		}
	}
	
	/* Parada de una VE */
	static public function Stop($VE)
	{
		if(VZ::ExisteVE($VE))
		{
			Sistema::Ejecuta(VZ::QueNodo($VE), "Parando container ".$VE, "vzctl stop ".$VE." &> /dev/null");
		}
		else
		{
			ERROR::Warn("No existe el container ".$VE.".", SALIR);
		}
	}
	
	/* Obtener un array con toda la configuración, sin comentarios */
	static public function GetaConf($VE)
	{
		$aConf = Sistema::Ejecuta(VZ::QueNodo($VE), "Leyendo configuración", "cat ".VZCONF_DIR."/".$VE.".conf", CRITICO, RUIDOSO, RET_ARRAY);
		return $aConf;		
	}
	
	/* Devuelve los valores de una opción de configuración */
	static public function GetConfValue($aConf, $opc)
	{
		foreach($aConf as $linea)
		{
			if(preg_match('/^\s*('.$opc.')\s*\=\s*\"(.*)\"/', $linea, $aRet))
			{
				if(preg_match('/^(\d*)\:(\d*)$/', $aRet[2], $aValores))
				{
					# Es un par de valores numéricos.
					# Devolver un array convertido a humano:
					$aHuman[] = $aValores[0];
					if(preg_match("/PAGES/", $opc))
					{
						# Calcular en páginas:
						$aHuman[] = Calc::pages2human($aValores[1]);
						$aHuman[] = Calc::pages2human($aValores[2]);						
					}
					else if(preg_match("/SIZE/", $opc))
					{
						# Calcular en bytes:
						$aHuman[] = Calc::bytes2human($aValores[1]);
						$aHuman[] = Calc::bytes2human($aValores[2]);
					}
					else
					{
						# No calcular:
						$aHuman[] = $aValores[1];
						$aHuman[] = $aValores[2];						
					}
					return $aHuman;
				}
				else
				{
					# Devolver una cadena:
					return $aRet[2];
				}
			}
		}
	}
	
	/* Devolver la descripción para una opción */
	public static function GetOpcDesc($opc)
	{
		$aDesc["ONBOOT"] 	= "Activar en arranque";
		$aDesc["KMEMSIZE"]	= "RAM estructuras kernel (unswappable)";
		$aDesc["LOCKEDPAGES"]	= "RAM bloqueda contra swap";
		$aDesc["PRIVVMPAGES"]	= "RAM privada";
		$aDesc["SHMPAGES"] 	= "Memoria compartida";
		$aDesc["NUMPROC"] 	= "Max. procesos que puede crear";
		$aDesc["PHYSPAGES"] 	= "RAM usada por procesos (accounting)";
		$aDesc["VMGUARPAGES"]	= "RAM garantizada";
		$aDesc["OOMGUARPAGES"]  = "Garantia Out-Of-Memory";
		$aDesc["NUMTCPSOCK"] 	= "Limite de sockets";
		$aDesc["NUMFLOCK"] 	= "Limite bloqueos de fichero";
		$aDesc["NUMPTY"] 	= "Limite de pseudo-terminales";
		$aDesc["NUMSIGINFO"] 	= "Limite estructuras siginfo";
		$aDesc["TCPSNDBUF"] 	= "Limite buffers envio";
		$aDesc["TCPRCVBUF"] 	= "Buffers recepcion";
		$aDesc["OTHERSOCKBUF"]  = "Buffers envio udp, datagramas...";
		$aDesc["DGRAMRCVBUF"] 	= "";
		$aDesc["NUMOTHERSOCK"]  = "";
		$aDesc["DCACHESIZE"] 	= "";
		$aDesc["NUMFILE"] 	= "";
		$aDesc["AVNUMPROC"]	= "";
		$aDesc["NUMIPTENT"] 	= "";
		$aDesc["DISKSPACE"] 	= "Limites de disco";
		$aDesc["DISKINODES"]	= "Limite de inodos";
		$aDesc["QUOTATIME"] 	= "";
		$aDesc["CPUUNITS"] 	= "";
		$aDesc["VE_ROOT"] 	= "";
		$aDesc["VE_PRIVATE"] 	= "";
		$aDesc["OSTEMPLATE"] 	= "";
		$aDesc["ORIGIN_SAMPLE"] = "";
		$aDesc["HOSTNAME"] 	= "Nombre de host";
		$aDesc["IP_ADDRESS"] 	= "Direccion IP";
		
		return $aDesc[$opc];
	}
}
