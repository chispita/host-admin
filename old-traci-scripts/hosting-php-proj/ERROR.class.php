<?php

Class ERROR
{
	public static function Warn($desc, $salir = true, $nivel = 1)
	{
		if($salir)
		{
			$aviso = "%rERROR";
		}
		else
		{
			$aviso = "%yAVISO";
		}
		
		decir("\n".$aviso." %b[".$nivel."]%n: ".$desc, 2);
		
		if($salir)
		{
			exit($nivel);
		}
	}
	
	public static function Debug($var, $titulo = "DEBUG")
	{
		Decir("%r*** ".$titulo." ***%n");	
		Decir(print_r($var, true));
		Decir("%r.................................%n");
	}
}

?>
