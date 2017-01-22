#!/sbin/sh
# Thanks to tkkg1994 & djb77
# Modified by morogoku

mount /system
mount -o remount,rw -t auto /system

# Edit build.prop
sed -i /ro.config.dmverity=/c\ro.config.dmverity=false /system/build.prop
sed -i /ro.config.rkp=/c\ro.config.rkp=false /system/build.prop
sed -i /ro.config.kap_default_on=/c\ro.config.kap_default_on=false /system/build.prop
sed -i /ro.config.kap=/c\ro.config.kap=false /system/build.prop
sed -i /ro.securestorage.support=/c\ro.securestorage.support=false /system/build.prop
sed -i /ro.frp.pst=/c\ro.frp.pst= /system/build.prop
sed -i /ro.build.selinux=/c\ro.build.selinux=0 /system/build.prop
sed -i /ro.config.knox=/c\ro.config.knox=0 /system/build.prop
sed -i /ro.config.tima=/c\ro.config.tima=0 /system/build.prop
sed -i /ro.config.timaversion=/c\ro.config.timaversion=0 /system/build.prop
sed -i /ro.config.iccc_version=/c\ro.config.iccc_version=0 /system/build.prop

sed -i /security.mdpp.mass/d /system/build.prop
sed -i /ro.hardware.keystore/d /system/build.prop


# Delete wrongs files
rm -rf /system/app/TuiService /system/app/mcRegistry
rm -f /system/vendor/lib/libsecure_storage.so
rm -f /system/vendor/lib/libsecure_storage_jni.so
rm -f /system/vendor/lib64/libsecure_storage.so
rm -f /system/vendor/lib64/libsecure_storage_jni.so


# Delete Wakelock.sh 
rm -f /magisk/phh/su.d/wavelock.sh
rm -f /su/su.d/wavelock.sh
rm -f /system/su.d/wavelock.sh

 
# Install Busybox if not exist
if [ ! -f "/system/xbin/busybox" ]; then
	mv /tmp/moro/busybox /system/xbin/busybox
	chmod 0755 /system/xbin/busybox
	ln -s /system/xbin/busybox /system/bin/busybox
	/system/xbin/busybox --install -s /system/xbin
fi
