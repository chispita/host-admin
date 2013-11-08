<?php

/*
 * Borra recursivamente un directorio.
 * CUIDADO: Esto dispara y luego ni pregunta.
 */

function BorraRecDir($DirBorrar)
{
	# ¿Existe?
	if(!file_exists($DirBorrar))
	{
        	return false;
        }
 
 	# Si es un fichero o un enlace lo borramos simplemente:
	if(is_file($DirBorrar) or is_link($DirBorrar)) {
        	return unlink($DirBorrar);
    	}
 
	# Recorremos el directorio:
	$contenido = dir($DirBorrar);
    	while(false !== $entrada = $contenido->read())
    	{
        	# Saltar puntos.
        	if ($entrada == '.' or $entrada == '..')
        	{
            		continue;
		}
 
		# Recursión:
        	BorraRecDir($DirBorrar.DIRECTORY_SEPARATOR.$entrada);
    	}
    	
    	# Cierre:
    	$contenido->close();
    	return rmdir($DirBorrar);
}