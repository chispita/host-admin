#!/usr/bin/php -q
<?php

#-------------------------------------------#
# chroot2all.php                            #
#...........................................#
#                                           #
# Script para la creación total de usuarios #
# y entornos chroot para sftp y ssh.        #
#                                           #
# Sincroniza los usuarios de la BDD con los #
# de sistema.                               #
#                                           #
# Crea los directorios y enlaces en su home #
# para el chroot.                           #
#                                           #
# queru@queru.org - calocen@qaop.com        #
# Enero de 2005.                            #
#                                           #
#-------------------------------------------#

require "DB.php";
require "File/Passwd.php";
require_once 'PHP/Compat.php';
PHP_Compat::loadFunction('file_put_contents');

# Constantes:
define("MINUID", 3000);
define("MAXUID", 65000);
define("APP_PATH", "/usr/local/admin/chroot");
define("CRYPT_STD_DES", 1);

echo "chroot2all - Conectahosting.com\n"
	."-------------------------------\n\n";

# Abrir /etc/passwd:
$passwd = &File_Passwd::factory('Unix');
$passwd->setFile('/etc/passwd');
$passwd->load();
$passwd->UseMap(true);

# Conectar con la BDD:
$dbh = DB::connect("mysql://toor:secuela.2@localhost");
if (DB::isError($dbh))
{
	die("\nERROR conexión MySQL:\n".$dbh->getMessage()."\n");
}

# En primer lugar comprobamos que no haya ningún usuario
# con UID mayor de MINUID que no esté en la BDD. De ser
# así entendemos que el usuario es baja en la BDD y por
# tanto nos lo cepillamos:
echo "+ Comprobando concordancia usuarios Unix->BDD:\n";
ForEach ($passwd->listUser() as $usuario => $datos)
{
	if ($datos['uid'] >= MINUID and $datos['uid'] <= MAXUID)
	{
		$result = $dbh->query("SELECT name,uid,gid,pwd,domain,chroot from cqtraci.ftp "
								."WHERE name='".$usuario."' AND chroot='si';");
		if (DB::isError($result)) {
			die ("\n\nERROR query:\n".$result->getMessage()."\n");
		}
		
		if ($result->numRows() == 0)
		{
			echo "\t* ".$usuario.": No existe en BDD o no tiene chroot. Borrando.\n";
			# Borrar el usuario:
			shell_exec("userdel ".$usuario);
			# Borrarlo del fichero de grupos:
			shell_exec("groupdel ".$usuario);
			# Le quitamos también el entorno chroot:
			$home = substr($datos['home'], 0, strpos($datos['home'], "/./"));
			# Desmontar la iso:
			#shell_exec("umount ".$home." &> /dev/null");
			rm_chroot($home);
		}
		else if ($result->numRows() == 1)
		{
			echo "\t+ ".$usuario.": Sincronizando password y chroot.\n";
			# Si ya existe y está en la BDD no hacemos nada salvo ajustar la passwd y asegurar
			# el entorno chroot.
			# Si se quieren hacer cambios en un usuario (nombre, uid, home...) es necesario
			# darlo de baja y de alta de nuevo.
			$home = substr($datos['home'], 0, strpos($datos['home'], "/./"));
			Crea_chroot($usuario, $home);
			# Ajustar la password:
			$row = $result->FetchRow(DB_FETCHMODE_ASSOC);
			# Una estupidez de la gentoo, el comando passwd no admite la password como argumento,
			# sólo deja cambiarla interactivamente, así que me he creado el comando yo:
			echo "\t\t- Ajustando passwd de ".$usuario." a ".$row['pwd']."\n";
			passthru(APP_PATH."/cambia_passwd.py ".$usuario." ".$row['pwd']);
		}
		else
		{
			echo "\t* ".$usuario.": ERROR: El usuario está duplicado (".$result->numRows().") en la BDD.\n";
		}
		$result->free();
		echo "\n";
	}
}

echo "* OK.\n";

# Comprobamos que todos los usuarios de la BDD que están
# marcados para tener CHROOT lo tengan.
echo "+ Comprobando concordancia usuarios BDD->Unix:\n";
$result = $dbh->query("SELECT name,uid,gid,pwd,home,domain,chroot from cqtraci.ftp WHERE chroot='si';");
if (DB::isError($result))
{
	die ("\n\nERROR query:\n".$result->getMessage()."\n");
}

While($row = $result->FetchRow(DB_FETCHMODE_ASSOC))
{
	$usuariolocal = $passwd->listUser($row['name']);
	if (PEAR::isError($usuariolocal))
	{
		# El usuario no existe localmente. Crearlo.
		echo "\t+ ".$row['name'].": Creando usuario y grupo...\n";
		# Crea el grupo:
		# Otra estupidez de la gentoo. En esta versión de las shadow-utils el
		# groupadd no admite nombres largos. Por eso añado los grupos medio a mano.
		if (strlen($row['name']) > 16)
		{
			shell_exec("groupadd -f -g ".$row['gid']." gr_sustituir");
			$grupos = file_get_contents("/etc/group") or die("\n\nERROR leyendo /etc/group.\n");
			$grupos = str_replace("gr_sustituir", $row['name'], $grupos);
			file_put_contents("/etc/group", $grupos);
			unset($grupos);
		}
		else
		{
			shell_exec("groupadd -f -g ".$row['gid']." ".$row['name']);
		}
		# Añade el usuario al /etc/passwd:
		if(empty($row['home']))
		{
			die("\n\tERROR: El home está vacío en la BDD.\n");
		}
		/* --------------------------------------------------------------
			Usage: useradd [-u uid [-o]] [-g group] [-G group,...] 
            	   	[-d home] [-s shell] [-c comment] [-m [-k template]]
	               	[-f inactive] [-e expire]
    	    		[-p passwd] name
 	        useradd -D [-g group] [-b base] [-s shell]
    	    		[-f inactive] [-e expire]
		   -------------------------------------------------------------- */
		shell_exec("useradd "
						."-u ".$row['uid']." "
						."-g ".$row['gid']." "
						."-G clientes "
						."-d ".$row['home']."/./htdocs "
						."-s /bin/sh "
						."-c \"Cliente con servicio chroot y sftp.\" "
						.$row['name']);
		echo "\t\t- Ajustando passwd de ".$row['name']." a ".$row['pwd']."\n";
		passthru(APP_PATH."/cambia_passwd.py ".$row['name']." ".$row['pwd']);
		# Crear el chroot:
		echo "\t+ Creando chroot...\n";
		Crea_chroot($row['name'], $row['home']);
		echo "\t\t- Home: ".$row['home']."\n";
	}
}

echo "* OK.\n";

# Desconectar de la BDD:
$dbh->disconnect();

echo "\n* Finalizado.\n";

/* -----------------------
	FUNCIONES ADICIONALES
   ----------------------- */

# Copia y monta el entorno chroot a un usuario.
# Funciona aunque ya esté creado.
Function Crea_chroot($usuario, $home)
{
	echo "\t\t+ Crear usuario: ".$usuario." Home: ".$home."\n";
	if (empty($usuario))
	{
		die("\n\nERROR: usuario vacío.\n\n");
	}
	if (empty($home))
	{
		die("\n\nERROR: home vacío.\n\n");
	}
	rm_chroot($home);
	"\t\t+ Copia último chroot a ".$home."/chroot-env\n";
	shell_exec("mkdir -p ".$home."/chroot-env");
	shell_exec("chown -R root:root ".$home."/chroot-env");
	shell_exec("chmod 775 ".$home."/chroot-env");
	shell_exec("mount -o ro,loop /usr/local/admin/chroot/chroot-env.iso ".$home."/chroot-env &> /dev/null");
	shell_exec("ln -s ".$home."/chroot-env/bin ".$home."/bin");
	shell_exec("ln -s ".$home."/chroot-env/dev ".$home."/dev");
	shell_exec("ln -s ".$home."/chroot-env/lib ".$home."/lib");
	shell_exec("ln -s ".$home."/chroot-env/usr ".$home."/usr");
	shell_exec("mkdir -p ".$home."/etc");
	shell_exec("cat /etc/passwd|grep ".$usuario." > ".$home."/etc/passwd");
	shell_exec("chown -R root:root ".$home."/etc");
	shell_exec("chmod -R 775 ".$home."/etc");
	shell_exec("chmod 664 ".$home."/etc/passwd");
}

Function rm_chroot($home)
{
	echo "\t\t+ Borrar chroot de ".$home."/chroot-env\n";
	if (empty($home))
	{
		die("\n\nERROR: home vacío.\n\n");
	}
	shell_exec("umount ".$home."/chroot-env &> /dev/null");
	shell_exec("rm -Rf ".$home."/chroot-env &> /dev/null");
	shell_exec("rm ".$home."/bin &> /dev/null");
	shell_exec("rm ".$home."/dev &> /dev/null");
	shell_exec("rm ".$home."/lib &> /dev/null");
	shell_exec("rm ".$home."/usr &> /dev/null");
	shell_exec("rm -Rf ".$home."/etc &> /dev/null");
}
  
# Borra un fichero o un directorio, con todo
# su contenido:

function rmdirr($dirname)
{
    // Comprobar que existe:
    if (!file_exists($dirname)) {
        return false;
    }
 
    // Simple borrado de un fichero:
    if (is_file($dirname)) {
        return unlink($dirname);
    }
 
    // Bucle a través del directorio:
    $dir = dir($dirname);
    while (false !== $entry = $dir->read()) {
        // Pasar de los puntos:
        if ($entry == '.' || $entry == '..') {
            continue;
        }
 
        // Recursivo:
        rmdirr("$dirname/$entry");
    }
 
    // Limpieza:
    $dir->close();
    return rmdir($dirname);
}
 
?>
