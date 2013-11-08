<?php

/*
 * (c)2008 Jorge Fuertes
 * queru@queru.org
 *
 */

class Cache
{
	# Vuelca una variable a caché:
	public static function Put($ref, $var)
	{
		file_put_contents(CACHE."/".$ref.".cache", "<?php\n"
			."# Cache ref: ".$ref."\n"
			."# Time: ".date("d-m-Y@H:i:s")."\n"
			."\n"
			."\$time = '".time()."';\n"
			."\$var = ".var_export($var, true).";\n"
			."?>");
		return true;
	}
	
	# Importa una variable del caché:
	public static function Get($ref)
	{
		if(file_exists(CACHE."/".$ref.".cache"))
		{
			require(CACHE."/".$ref.".cache");
			return($var);
		}
		else
		{
			return false;
		}
	}
	
	# Existe en el caché?:
	public static function Exists($ref)
	{
		if(file_exists(CACHE."/".$ref.".cache"))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	# DelRef: Borra una referencia del caché:
	public static function DelRef($ref)
	{
		if(file_exists(CACHE."/".$ref.".cache"))
		{
			unlink(CACHE."/".$ref.".cache");
			return true;
		}
		else
		{
			return false;
		}
	}
	
	# DelAll: Borra todo el caché:
	public static function DelAll()
	{
		if(strlen(CACHE) > 2)
		{
			if(is_dir(CACHE))
			{
				system("rm -f ".CACHE."/* &> /dev/null");
			}
			else
			{
				ERROR::Warn("No existe el directorio de caché");
			}
		}
		else
		{
			ERROR::Warn("La directiva de configuración 'CACHE' está vacía");
		}
	}
}

?>