#!/system/bin/sh
# 
# Init MoRoKernel
#

MORO_DIR="/data/.morokernel"
LOG="$MORO_DIR/morokernel.log"

rm -f $LOG

BB="/sbin/busybox"
RESETPROP="/sbin/resetprop -v -n"


# Mount
mount -t rootfs -o rw,remount rootfs;
mount -o rw,remount /system;
mount -o rw,remount /data;
mount -o rw,remount /;


# Create morokernel folder
if [ ! -d $MORO_DIR ]; then
    mkdir -p $MORO_DIR;
fi


# Scripts folder
if [ -f /sbin/moro_init.sh ]; then
    SDIR=/sbin
else
    SDIR=$MORO_DIR/scripts
fi


(
# Init log file
echo $(date) "MoRo-Kernel LOG" >> $LOG;
echo " " >> $LOG;


# Fix personalist error
. $SDIR/fix_personalist.sh

# Install apk
. $SDIR/install_apk.sh

# Init.d
. $SDIR/init_d.sh

# Tweaks
. $SDIR/tweaks.sh


) 2>&1 | tee -a ./$LOG;


# Unmount
mount -t rootfs -o ro,remount rootfs;
mount -o ro,remount /system;
mount -o rw,remount /data;
mount -o ro,remount /;

