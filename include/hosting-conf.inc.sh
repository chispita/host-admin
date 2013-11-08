# Configuración para los scripts de Hosting:

APP_PATH="/usr/local/admin"
source $APP_PATH/include/colores.inc.sh
source $APP_PATH/include/funciones.inc.sh

# OpenVZ:
OPENVZ_DIR="/var/lib/vz/private"

# Correo:
MAIL_VEID="106"
MAIL_DIR="/var/mail/virtual"
MAIL_DOMS="$OPENVZ_DIR/$MAIL_VEID/$MAIL_DIR"

# DNS:
DNS_VEID="103"
DNS_CMD="/usr/local/admin/rctinydns.sh"

# WEB:
INSIDE_WEB_VEID="110"
INSIDE_WEB_DIR="$OPENVZ_DIR/$INSIDE_WEB_VEID/var/www"
RAPIDO_WEB_VEID="109"
RAPIDO_WEB_DIR="$OPENVZ_DIR/$RAPIDO_WEB_VEID/var/www"
WEB_UID="33"
WEB_GID="33"
WEB_BKDIR="$WEB_DIR/00_disabled"

# Backups:
BACKUP_DIR="/backup/hosting"

# Base de datos:
BDD_HOST="192.168.100.11"
BDD_PRE="hs_"
