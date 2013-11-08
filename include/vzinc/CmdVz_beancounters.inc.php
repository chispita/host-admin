<?php

/* Compruenba los beamcounters de todas los containers */

# Primero llamamos a cada nodo y nos traemos copia de todos los beamcounters con errores:

$aNodos = VZ::getNodos();

decir("> Comprobando beancounters de todos los nodos.");

foreach($aNodos as $nodo)
{
	$aTmp = Sistema::Ejecuta($nodo, "",
		"/usr/local/admin/get_bean_errors.sh",
		NO_CRITICO, SILENCIOSO, RET_ARRAY);

	# Parseamos el nuevo:
	$aBeansNew = BeanParse($aTmp);
	unset($aTmp);

	# Cargamos el viejo:
	$aBeansOld = LoadBeans();

	# Guardamos el nuevo en su lugar:
	SaveBeans($aBeansNew);

	# Si el viejo estaba vacío no hay nada que hacer:
	if(!$aBeansOld)
	{
		Decir("Nada con qué comparar.");
		exit(0);
	}
	else
	{
		# Comparamos el viejo con el nuevo:
		$aDiff = array_diff($aBeansNew, $aBeansOld);
		if(empty($aDiff))
		{
			Decir("No han cambiado.", 2);
			exit(0);
		}
		else
		{
			Decir("Los siguientes beancounters han cambiado:", 2);
			foreach($aDiff as $linea)
			{
				$aLinea = explode("|", $linea);
				Decir(" - ".$aLinea[0].": ".$aLinea[1]." --> ".$aLinea[2]);
				exit(1);
			}
		}
	}
}

/* FUNCIONES */
function LoadBeans()
{
	# Cargamos los beans de fichero:
	if(file_exists(BEANFILE))
	{
		$aBeans = array();
		$fBeans = @fopen(BEANFILE, "r");
		while (!feof($fBeans))
		{
        		$aBeans[] = trim(fgets($fBeans, 4096));
	        }
        	fclose($fBeans);
	        return $aBeans;
	}
	else
	{
		return false;
	}
}

function SaveBeans($aBeans)
{
	# Guardamos los beans:
	$fBeans = fopen(BEANFILE, 'w');
	foreach($aBeans as $linea)
	{
		fwrite($fBeans, $linea."\n");
	}
	fclose($fBeans);
	# Copiando a todos los nodos:
	$aNodos = VZ::getNodos();
	foreach($aNodos as $nodo)
	{
		if($nodo != ESTE_NODO)
		{
			Sistema::Ejecuta(ESTE_NODO, "Copiando a ".$nodo, "scp ".BEANFILE." root@".$nodo.":".BEANFILE, NO_CRITICO);
		}
	}
}

function BeanParse($aBeans)
{
	if(empty($aBeans))
	{
		ERROR::Warn("BeanParse: Array vacío.");
	}
	elseif(!is_array($aBeans))
	{
		ERROR::Warn("BeanParse: no es un array: ".print_r($aBeans, true));
	}
	
	$aOut = array();
	foreach($aBeans as $linea)
	{
		$aLinea = explode("|", $linea);
		$aOut[] = $aLinea[0]."|".$aLinea[1]."|".$aLinea[6];
	}
	return $aOut;
}

?>
