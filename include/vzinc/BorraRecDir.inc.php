<?php

/*
 * Borra recursivamente un directorio.
 * CUIDADO: Esto dispara y luego ni pregunta.
 */

function BorraRecDir($DirBorrar)
{
	if(empty($DirBorrar) or $DirBorrar == "/")
	{
		echo "\nERROR: no puedo borrar '".$DirBorrar."'\n";
		return false;
	}
	# ¿Existe?
	if(!file_exists($DirBorrar))
	{
		echo "\nERROR: no existe '".$DirBorrar."'\n";
        	return false;
        }

	echo "> Borrando '".$DirBorrar."'...";
	passthru("rm -Rf ".$DirBorrar, $errorlevel);
	if($errorlevel == 0)
	{
		echo "OK\n";
		return true;
	}
	else
	{
		echo "FALLO\n";
		return $errorlevel;
	}
}
