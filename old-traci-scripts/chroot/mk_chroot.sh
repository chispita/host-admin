#!/bin/sh

# Crea la ISO con el entorno chroot.

CHROOT_DIR=/usr/local/admin/chroot/enviroment

REQUIRED_CHROOT_FILES=" /bin/cp \
                        /bin/ls \
                        /bin/mkdir \
                        /bin/mv \
                        /bin/rm \
                        /bin/rmdir \
                        /bin/sh \
			/bin/gzip \
			/bin/bzip2 \
			/bin/tar \
			/usr/bin/wget \
			/usr/lib/misc/sftp-server \
                        /lib/libnss_files.so.2"

DIR_ACTUAL=$(pwd)

DIRAPP=/usr/local/admin/chroot

# Create CHROOT_DIR
echo "Crear directorio CHROOT..."
[ ! -d $CHROOT_DIR ] && mkdir -p $CHROOT_DIR
cd $CHROOT_DIR

# Copy REQUIRED_CHROOT_FILES and shared library dependencies
# to chroot environment


for FILE in $REQUIRED_CHROOT_FILES
do
   DIR=`dirname $FILE | cut -c2-`
   [ ! -d $DIR ] && mkdir -p $DIR
   echo -n "Copiando $FILE a $(echo $FILE | cut -c2-) "
   cp $FILE `echo $FILE | cut -c2-`
   echo "y bibliotecas asociadas..."
   for SHARED_LIBRARY in `ldd $FILE | awk '{print $3}'|grep -v "(0x"`
   do
      DIR=`dirname $SHARED_LIBRARY | cut -c2-`
      [ ! -d $DIR ] && mkdir -p $DIR
      [ ! -s "`echo $SHARED_LIBRARY | cut -c2-`" ] && cp $SHARED_LIBRARY `echo $SHARED_LIBRARY | cut -c2-`
   done
done

# Create device files
echo "Creando devices..."
mkdir -p $CHROOT_DIR/dev
mknod $CHROOT_DIR/dev/null c 1 3 &> /dev/null
mknod $CHROOT_DIR/dev/zero c 1 5 &> /dev/null

echo "Creando iso..."
mkisofs -iso-level 3 -J -allow-leading-dots -R -U --no-iso-translate $CHROOT_DIR > $DIRAPP/chroot-env.iso

cd $DIR_ACTUAL

echo "Finalizado."

