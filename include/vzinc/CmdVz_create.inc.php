<?php

  /*
   * Creación de una VE.
   *
   * Ejemplo:
   *   vzctl create 102 --ostemplate debian-etch-20061218-amd64 --config vps.basic
   *   vzctl set 102 --onboot yes --save
   *   vzctl set 102 --hostname test102.mytest.org --save
   *   vzctl set 102 --ipadd 10.0.0.102 --save
   *   vzctl set 102 --numothersock 120 --save
   *   vzctl set 102 --nameserver 10.0.0.2 --save
   *   vzctl set 102 --privvmpages 500000:750000 --save
   *   vzctl set 1 --userpasswd root:epepep45
   *
   */

$VElista = VZ::GetVEs();

// Si no se especifica ID y no hay VEs en el sistema, asignamos el ID 101.
if(empty($VElista) and empty($VE)) $VE = "101";

if(!empty($VE))
  {
    // Si se especifica un ID nos aseguramos de que está libre.
    if(array_search($VE, $VElista) !== false)
      {
	ERROR::Warn("La VE ".$VE." ya está en uso. Elija otro ID o no lo especifique.", SALIR);
      }
  }
else
  {
    // Si no se especifica ID buscamos el primero libre.
    $VElast = 100;
    foreach($VElista as $VEocupada)
      {
	if($VEocupada > $VElast+1)
	  {
	    $VE = strval($VElast+1);
	    break;
	  }
	$VElast = $VEocupada;
      }
    if(empty($VE)) $VE = $VElast + 1;
    decir("%b> INFO%n: Primer ID libre: ".$VE.".");
  }	

// ID:
$VE = input("¿%yID%n numérico?", $VE);


# -----=[ Nodo en el que crear ]=-----
$defecto = array_search(ESTE_NODO, VZ::getNodos());
$NODO    = Consola::Array2Menu(VZ::getNodos(), RET_VALUE, $defecto, "Nodos", "Seleccione el nodo donde desea crear");

# -----=[ Template: ]=-----
# Escanear directorio de templates:
$aTemplates = scandir(TEMPLATE_DIR);
# Quitar el '.' y el '..':
array_shift($aTemplates); array_shift($aTemplates);
# Quitar el '.tar.gz':
foreach($aTemplates as $key => $template)
{
	$aTemplates[$key] = ereg_replace(".tar(.gz|.bz)$", "", $template);
}

$template = Consola::Array2Menu($aTemplates, RET_VALUE, 0, "Templates", "Seleccione template");

// Config:
# Escanear dir de confs:
$aConfs = Sistema::Ejecuta(ESTE_NODO, "", "ls -C1 ".VZCONF_DIR."/*.conf-sample", CRITICO, SILENCIOSO, RET_ARRAY);
foreach($aConfs as $key => $conf)
{
	$conf         = ereg_replace("^".VZCONF_DIR."/ve\-", "", $conf);
	$aConfs[$key] = ereg_replace("\.conf\-sample$", "", $conf);
}

$vps = Consola::Array2Menu($aConfs, RET_VALUE, 0, "Configuración", "Elija una configuración:");

// Hostname:
$hostname = input("¿Hostname (sin dominio)?", "ve".$VE);
// Dominio:
$dn = input("¿Dominio?", "ibercivis.es");
// Memoria:
while(true)
{
	decir("%b> INFO%n: Memoria 'barrier'. Se especifica según el sufijo G (Gigas), M (Megas), K (Kilobytes), P (Páginas de 4096b).\n", 0);
	$membarrier = input("¿Memoria asignada?", "128M");
	$memlimit = input("¿Límite de memoria?", "200M");
	if((is_numeric($membarrier) and $membarrier < 16384) or (is_numeric($memlimit) and $memlimit < 16384))
	{
		ERROR::Warn("Creo que está asignando poca memoria. Utilice un sufijo 'G,M,K o P' o asigne más memoria.", CONTINUAR);
	}
	else
	{
		break;
	}
}
// Pass root:
$rootpass = input("¿Contraseña de root?", "gnu.ve-".$VE);
// IP interna:
$IpInt = Cidr::getIpForId($VE);

// Creación de la máquina:
decir("\n%6%k + Creación del entorno virtual ".$VE.": + %n", 2);
Sistema::Ejecuta($NODO, "Creando la VE", "vzctl create ".$VE." --ostemplate ".$template." --config ".$vps);
Sistema::Ejecuta($NODO, "Activando en el arranque", "vzctl set ".$VE." --onboot yes --save");
Sistema::Ejecuta($NODO, "Hostname", "vzctl set ".$VE." --hostname ".$hostname.".".$dn." --save");
Sistema::Ejecuta($NODO, "Asignando IP ".$IpInt, "vzctl set ".$VE." --ipadd ".$IpInt." --save");
Sistema::Ejecuta($NODO, "Nameserver ".DNSCACHE, "vzctl set ".$VE." --nameserver ".DNSCACHE." --onboot yes --save");
Sistema::Ejecuta($NODO, "Asignando memoria", "vzctl set ".$VE." --privvmpages ".$membarrier.":".$memlimit." --save");
Sistema::Ejecuta($NODO, "Passwd de root", "vzctl set ".$VE." --userpasswd root:".$rootpass);
Sistema::Ejecuta($NODO, "Creando directorio admin", "mkdir -p /vz/private/".$VE."/usr/local/admin/include");
Sistema::Ejecuta($NODO, "Copiando profile-admin", "cp ".ADMIN_DIR."/profile.local.sh /vz/private/".$VE."/usr/local/admin/.");
Sistema::Ejecuta($NODO, "Copiando colores", "cp ".ADMIN_DIR."/include/colores.inc.sh /vz/private/".$VE."/usr/local/admin/include/.");
Sistema::Ejecuta($NODO, "Creando banner de entrada", BANNER." ".$hostname." > /vz/private/".$VE."/usr/local/admin/hostname.banner");
Sistema::Ejecuta($NODO, "Ajustando banner", "echo ' .".$dn." (".$IpInt.")' >> /vz/private/".$VE."/usr/local/admin/hostname.banner");
Sistema::Ejecuta($NODO, "Ajustando profile", "echo -e '\nsource /usr/local/admin/profile.local.sh\n' >> /vz/private/".$VE."/etc/profile");
Sistema::Ejecuta($NODO, "Copiando bashrc", "cp /root/.bashrc /vz/private/".$VE."/root/.");
Sistema::Ejecuta($NODO, "Ajustando permisos", "chmod 755 /vz/private/".$VE);
Sistema::Ejecuta($NODO, "Arrancando la VE", "vzctl start ".$VE, false);

# Anular el caché:
Cache::DelAll();

Decir("\n%g>%n Finalizado.");

// Info entrar:
Decir("%b[INFO]%n: Recuerde, para entrar en la VE: 'vze ".$VE."' o 'ssh ".$IpInt."'.");
sleep(2);

// Informe final:
$informe = 
	"- Servidor físico....: ".HOST_FQDN."\n"
      	."- Plantilla..........: ".$template."\n"
      	."- Configuración......: ".$vps."\n"
      	."- Arranca en el boot.: Si\n"
      	."- Hostname...........: ".$hostname."\n"
      	."- IP interna.........: ".$IpInt."\n"
      	."- Memoria............: ".$membarrier.":".$memlimit."\n"
      	."- Pass root..........: ".$rootpass."\n";
Decir("\n%6%k+ INFORME CREACION VE ".$VE.": +%n\n".$informe);

?>
