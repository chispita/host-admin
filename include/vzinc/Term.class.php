<?php

/*
 * Manejo del terminal
 *
 */
 
class Term
{
	private $col = 0;
		
	# Envía algo al terminal:
	private function send($txt)
	{
		$this->col = getCol();
		passthru('echo -en "'.$txt.'"');
	}
	
	# Envía algo al terminal y recoge la salida:
	private function sendrecv($txt)
	{
		return shell_exec('echo -en "'.$txt.'"');
	}
	
	# Devuelve la columna en la que se encuentra el cursor:
	private function getCol()
	{
		$crudo = $this->sendrecv("\e[6n");
		preg_match("/([0-9]*)/", $crudo, $aMatches);
		print_r($aMatches);
		decir("Crudo: ".$crudo);
	}
	
	public function test()
	{
		$this->getCol();
	}
}

?>