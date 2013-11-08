<?php

  /**
   * Configuración general comando vz
   */

# Modo DEBUG:
#DEBUG="";
define("DEBUG", true);

# Utilis:
define("BANNER", "/usr/bin/figlet");

# Temporales:
define("TMPDIR", "/tmp");
define("BEANFILE", TMPDIR."/beancounters.errors");

# Admin:
define("ADMIN_DIR", "/usr/local/admin");

# App:
define("APPDIR",     "/usr/local/admin");
define("INCLUDEDIR", APPDIR."/include/vzinc");

# Caché:
define("CACHE", APPDIR."/cache");

# OpenVZ:
define("VEDIR",	     "/vz/private");
define("TEMPLATE_DIR", "/vz/template/cache");
define("VZCONF_DIR",   "/etc/vz/conf");
define("CMD_VZCTL",    "/usr/sbin/vzctl");
define("CMD_VZDUMP",   "/usr/sbin/vzdump");
define("CMD_VZLIST",   "/usr/sbin/vzlist");

# Este servidor físico:
define("HOST_FQDN", trim(shell_exec("hostname -f")));
define("ESTE_NODO", HOST_FQDN);
define("HOST_VZNUMBER", "100");

# Esta red:
define("NET_DN", "ibercivis.es");

# Despligue IP:
define("RANGO_IP_VES", "192.168.100.1/22");

# Host mínimo por convenio OVZ:
define("VEID_MIN", "101");

# Nodos de OpenVZ:
define("OVZ_NODES", "srv1.ibercivis.es, srv2.ibercivis.es, srv3.ibercivis.es, srv4.ibercivis.es, node3.ibercivis.es, node4.ibercivis.es");

# Definición de pares de backup:
$aParesBk = array(
		"srv1.ibercivis.es"    => "srv1.ibercivis.es",
		"srv2.ibercivis.es"    => "srv2.ibercivis.es",
		"srv3.ibercivis.es"    => "srv3.ibercivis.es",
		"srv4.ibercivis.es"    => "srv4.ibercivis.es",
		"node3.ibercivis.es"   => "node3.ibercivis.es",
        "node4.ibercivis.es"   => "node4.ibercivis.es"
		);
if(array_key_exists(ESTE_NODO, $aParesBk))
{
	define("PAR_BACKUP", $aParesBk[ESTE_NODO]);
}
else
{
	ERROR::Warn(ESTE_NODO." no tiene par de backup definido.", false);		
}

# Nodo maestro (origen de templates, etc...):
# (Debe ser también el primero de la lista anterior de nodos del cluster)
define("OVZ_MASTER_NODE", "srv1.ibercivis.es");

# Servidores de DNS autoritativos:
# Simplemente para comprobarlos desde 'vz dnscheck'.
define("DNSAUTH", "ns3.ibercivis.es, ns1.ibercivis.es");

# Servidor dns-caché:
define("DNSCACHE", "192.168.100.254");

?>
