<?php

  /**
   * Configuración general comando vz
   */

# Modo DEBUG:
define(DEBUG, true);

# Admin:
define(ADMIN_DIR, "/usr/local/admin");

# App:
define(APPDIR,     "/usr/local/admin");
define(INCLUDEDIR, APPDIR."/hosting-include");

# OpenVZ:
define(VEDIR,	     "/vz/private");
define(VEID_MYSQL,    101);
define(VEID_DNS,      102);
define(VEID_CORREO,   106);
define(VEID_CHEROKEE, 107);
define(VEID_APACHE,   110);

# Servidores de DNS autoritativos:
define(DNSAUTH, "ns1.traci.es, ns2.traci.es");

# Informes:
define(HOSTING_NAME, "Conectahosting.es");
define(SOPORTE, "soporte@conectahosting.com");

?>
