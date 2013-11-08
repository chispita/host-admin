#!/usr/bin/php
<?php
	// Directorio donde se guardan los mensajes:
	define("DIRLOG", "/var/log/sendmail");

	$id = tempnam(DIRLOG, date("d-m-Y-@H:i:s_"));

	$mensaje = "> ID Interno.: $id\n"
		  ."> Comando....:";

	foreach($argv as $argumento)
	{
		$mensaje .= " $argumento";
	}

	$mensaje .= "\n\n> Cuerpo:\n\n";

	$mensaje .= fgets(STDIN, 4*1024*1024);

	// Crear un fichero log con el mensaje:
	file_put_contents($id, $mensaje);

	// Lanzarlo al auténtico sendmail:


/*
 * Funciones:
 */

 define('FILE_APPEND', 1);
 function file_put_contents($n, $d, $flag = false) {
     $mode = ($flag == FILE_APPEND || strtoupper($flag) == 'FILE_APPEND') ? 'a' : 'w';
     $f = @fopen($n, $mode);
     if ($f === false) {
         return 0;
     } else {
         if (is_array($d)) $d = implode($d);
         $bytes_written = fwrite($f, $d);
         fclose($f);
         return $bytes_written;
     }
 }

?>