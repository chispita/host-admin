<?php

  /*
   * Manejo de la consola
   *
   */

    class Consola
    {
        /**
        * Stdin file pointer
        */
        public static $stdin;


        /**
        * Returns stdin file pointer
        *
        * @return resource STDIN file pointer
        */
        private static function GetStdin()
        {
            if (!self::$stdin) {
                self::$stdin = fopen('php://stdin', 'r');
            }
            
            return self::$stdin;
        }


        /**
        * Pauses execution until enter is pressed
        */
        public static function Pause()
        {
            
            fgets(self::GetStdin(), 8192);
        }
        
        
        /**
        * Asks a boolean style yes/no question. Valid input is:
        *
        *  o Yes: 1/y/yes/true
        *  o No:  0/n/no/false
        *
        * @param string $question The string to print. Should be a yes/no
        *                         question the user can answer. The following
        *                         will be appended to the question:
        *                         "[Yes]/No"
        * @param bool   $default  The default answer if only enter is pressed.
        */
        public static function SioNo($question, $default = null)
        {
            if (!is_null($default)) {
                $defaultStr = $default ? '[Si]/No' : 'Si/[No]';
            } else {
                $defaultStr = 'Si/No';
            }
            
            $fp = self::GetStdin();
            
            while (true) {
                Decir($question." ".$defaultStr.": ", 0);
                $response = trim(fgets($fp, 8192));
                
                if (!is_null($default) AND $response == '') {
                    return $default;
                }
    
                switch (strtolower($response)) {
                    case 's':
                    case '1':
                    case 'si':
                    case 'true':
                        return true;
                    
                    case 'n':
                    case '0':
                    case 'no':
                    case 'false':
                        return false;
                    
                    default:
                        continue;
                }
            }
        }
    

        /**
        * Clears the screen. Specific to Linux (and possibly bash too)
        */
        public static function ClearScreen()
        {
            echo chr(033), "cm";
        }
        
        
        /**
        * Returns a line of input from the screen with the corresponding
        * LF character appended (if appropriate).
        *
        * @param int $buffer Line buffer. Defaults to 8192
        */
        public static function GetLine($buffer = 8192)
        {
            return fgets(self::GetStdin(), $buffer);
        }

	/**
	 * Obtiene un input pero sin el LF de los cojones.
	 */
	public static function GetInput($buffer = 512)
	{
	  return trim(fgets(self::GetStdin(), $buffer), "\n\r\t\0");
	}
	
	# Muestra un menú a partir de un array con key-id.
	# Devuelve la opcion selecionada en un string.
	public static function Array2Menu($aOpciones, $devolver_valor = true, $defecto = "0",
						$titulo = "Opciones", $input = "Seleccione una opción")
	{
		while(true)
		{
			decir("  %b--=[%y".$titulo."%b]=--%n");
			foreach($aOpciones as $key => $opcion)
			{
				$opcion = trim($opcion);
				decir("  %b[%w".$key."%b]%c ".$opcion."%n");
			}
			$keysel = input($input, $defecto);
			
			if(array_key_exists($keysel, $aOpciones))
			{
				if($devolver_valor)
				{
					$opc = trim($aOpciones[$keysel]);
					Decir("  %m".$opc."%n", 2);
					return trim($opc);
				}
				else
				{
					Decir("  %m".$keysel."%n", 2);
					return $keysel;
				}
			}
			else
			{
				ERROR::Warn("Opción ".$keysel." no existe.", CONTINUAR);
			}
		}
	}
    }
?> 