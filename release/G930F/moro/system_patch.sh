#!/sbin/sh
# Thanks to tkkg1994 & djb77
# Modified by morogoku


# Edit build.prop
sed -i /security.mdpp.mass/d /system/build.prop
sed -i /ro.hardware.keystore/d /system/build.prop


# Delete wrongs files
rm -rf /system/app/TuiService /system/app/mcRegistry
rm -f /system/vendor/lib/libsecure_storage.so
rm -f /system/vendor/lib/libsecure_storage_jni.so
rm -f /system/vendor/lib64/libsecure_storage.so
rm -f /system/vendor/lib64/libsecure_storage_jni.so


# Delete Wakelock.sh 
rm -f /magisk/phh/su.d/wakelock*
rm -f /su/su.d/wakelock*
rm -f /system/su.d/wakelock*
rm -f /system/etc/init.d/wakelock*


