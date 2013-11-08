<?php

class Sistema
{

	/**
	* Ejecución de comandos con control de errores.
	* Si $critico se detiene la ejecución del programa si hay un error.
	* Si $silencioso no se cantan los errores.
	*/
	public static function Ejecuta($nodo = HOST_FQDN, $desc, $cmd, $critico = true, $silencioso = false, $retarray = false)
	{
		if(!strstr(OVZ_NODES, $nodo))
		{
			ERROR::Warn("El nodo ".$nodo." no está registrado en el cluster.", SALIR);
		}
		
		if(!empty($desc)) decir("%g>%n ".$desc."...", 0);
		
		if($nodo == ESTE_NODO)
		{
	    		exec($cmd, $aSalida, $nNivel);
	    	}
	    	else
	    	{
	    		exec("ssh root@".$nodo." -C \"".$cmd."\"", $aSalida, $nNivel);
	    	}
	    	
	    	if($nNivel != 0)
	      	{
	      		if(!$silencioso or !empty($desc))
	      		{
				decir("%rFALLO%n.");
			}
	      		if(!$silencioso)
	      		{
				decir("%1%w !ERROR ejecutando comando externo! %n");
				decir("%1%w NODO:%n ".$nodo);
				decir("%b>%n ".$cmd);
				decir("%g> Salida%n:");
				foreach($aSalida as $linea)
				{
					decir("	".$linea);
				}
				if($critico)
				{
					ERROR::Warn("Ejecutando comando.", SALIR, 2);
				}
			}
			if($retarray)
			{
				return $aSalida;
			}
			else
			{
				return false;
			}
	      	}
	    	else
	      	{
			if(!$silencioso or !empty($desc)) decir("%gOK%n.");
			if($retarray)
			{
				return $aSalida;
			}
			return true;
	      	}
	}	

	/**
	* Ejecución de comandos con nivel de salida.
	* Si $silencioso no se cantan los errores.
	*/
	public static function ExecLevel($nodo = HOST_FQDN, $cmd, $silencioso = false)
	{
		if(!strstr(OVZ_NODES, $nodo))
		{
			ERROR::Warn("El nodo ".$nodo." no está registrado en el cluster.", SALIR);
		}
				
		if($nodo == ESTE_NODO)
		{
	    		exec($cmd, $aSalida, $nNivel);
	    	}
	    	else
	    	{
	    		exec("ssh root@".$nodo." -C \"".$cmd."\"", $aSalida, $nNivel);
	    	}
	    	
	    	if($nNivel != 0)
	      	{
	      		if(!$silencioso)
	      		{
				decir("%1%w !ERROR ejecutando comando externo! %n");
				decir("%1%w NODO:%n ".$nodo);
				decir("%b>%n ".$cmd);
				decir("%g> Salida%n:");
				foreach($aSalida as $linea)
				{
					decir("	".$linea);
				}
			}
	      	}

		return $nNivel;
	}
	
	/*
	 * Borra recursivamente un directorio.
	 * CUIDADO: Esto dispara y luego ni pregunta.
	 */

	public static function BorraRecDir($DirBorrar)
	{
		if(empty($DirBorrar) or $DirBorrar == "/")
		{
			ERROR::Warn("No puedo borrar '".$DirBorrar."'", CONTINUAR);
			return false;
		}
		# ¿Existe?
		if(!file_exists($DirBorrar))
		{
			ERROR::Warn("No existe '".$DirBorrar."'", CONTINUAR);
	        	return false;
	        }
	
		decir("%g>%n Borrando '".$DirBorrar."'...", 0);
		passthru("rm -Rf ".$DirBorrar, $errorlevel);
		if($errorlevel == 0)
		{
			decir("%gOK%n");
			return true;
		}
		else
		{
			decir("%rFALLO%n");
			return $errorlevel;
		}
	}
}

?>
