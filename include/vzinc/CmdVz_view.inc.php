<?php

/* Lista características de un container */

if(empty($VE))
{
	ERROR::Warn("Especifique número de container", SALIR, 1);
}

if(!VZ::ExisteVE($VE))
{
	ERROR::Warn("No existe el container $VE.", SALIR, 1);
}

# Obtener configuración:
$aConf = VZ::GetaConf($VE);

Decir("%4%w Container ".$VE." en ".VZ::QueNodo($VE)." %n");

# Queremos ver toda la conf:
$aSalida = array();
foreach($aConf as $linea)
{
	# parsear:
	if(preg_match("/^(\w*)\=/", $linea, $aOpc))
	{
		$opc = $aOpc[1];
		$aValores = VZ::GetConfValue($aConf, $opc);
		$desc = VZ::GetOpcDesc($opc);
		if(is_array($aValores))
		{
			$aSalida[] = array("opc" => $opc, "valora" => $aValores[1], "valorb" => $aValores[2], "desc" => $desc);
		}
		else
		{
			if(strlen($aValores) > 50)
			{
				$wrapped = wordwrap($aValores, 50, "¡");
				$valores = preg_split("/\¡/", $wrapped);
				$cont = 0;
				foreach($valores as $v)
				{
					if($cont == 0)
					{
						$aSalida[] = array("opc" => $opc, "valora" => $v, "valorb" => "", "desc" => $desc);
					}
					else
					{
						$aSalida[] = array("opc" => "", "valora" => $v, "valorb" => "", "desc" => "");
					}
					$cont++;
				}
		
			}
			else
			{
				$aSalida[] = array("opc" => $opc, "valora" => $aValores, "valorb" => "", "desc" => $desc);
			}
		}
	}	
}

# tabular:
$col_opc = 0; $col_valor = 0; $col_desc = 0;
foreach($aSalida as $linea)
{
	if(strlen($linea["opc"]) > $col_opc) $col_opc = strlen($linea["opc"]);
	if(!empty($linea["valorb"]))
	{
		$valorlen = strlen($linea["valora"]."/".$linea["valorb"]);
	}
	else
	{
		$valorlen = strlen($linea["valora"]);
	}
	if($valorlen > $col_valor) $col_valor = $valorlen;
	if(strlen($linea["desc"]) > $col_desc) $col_desc = strlen($linea["desc"]);
}
# mostrar:
#Decir("|".str_pad($col_opc, $col_opc)."|".str_pad($col_valor, $col_valor)."|".str_pad($col_desc, $col_desc)."|");
Decir("+".str_repeat("-", $col_opc)."+".str_repeat("-", $col_valor)."+".str_repeat("-", $col_desc)."+");
Decir("|".str_pad("Parametro:", $col_opc)."|".str_pad("Valores:", $col_valor)."|".str_pad("Descripcion:", $col_desc)."|");
Decir("+".str_repeat("-", $col_opc)."+".str_repeat("-", $col_valor)."+".str_repeat("-", $col_desc)."+");
foreach($aSalida as $linea)
{
	if(!empty($linea["valorb"]))
	{
		$valor = "%g".$linea["valora"]."%n/%r".$linea["valorb"]."%n";
		$restar = 8;
	}
	else
	{
		$valor = "%y".$linea["valora"]."%n";
		$restar = 4;
	}
	Decir("|%c".str_pad($linea['opc'], $col_opc)."%n|".str_pad($valor, $col_valor + $restar)."|".str_pad($linea['desc'], $col_desc)."|");
	#print_r($linea);
}
Decir("+".str_repeat("-", $col_opc)."+".str_repeat("-", $col_valor)."+".str_repeat("-", $col_desc)."+");

?>
