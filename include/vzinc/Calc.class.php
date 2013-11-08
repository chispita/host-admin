<?php

class Calc
{
	# Convierte un valor en bytes a una cadena inteligible
	# terminada en K, M, o G.
	public static function bytes2human($bytes)
	{
		if($bytes < 1024)
		{
			return $bytes."b";
		}
		else if($bytes < 1024*1024)
		{
			return round(($bytes/1024),1)."k";
		}
		else if($bytes < 1024*1024*1024)
		{
			return round(($bytes/1024/1024),1)."M";
		}
		else
		{
			return round(($bytes/1024/1024/1024),1)."G";
		}
	}
	
	# Convierte páginas de 4Kb a humano:
	public static function pages2human($pages)
	{
		return self::bytes2human($pages*4096);
	}
}

?>