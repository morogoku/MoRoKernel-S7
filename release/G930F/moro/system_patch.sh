#!/sbin/sh

rm -rf /system/app/mcRegistry
rm -f /system/vendor/lib/libsecure_storage.so
rm -f /system/vendor/lib64/libsecure_storage.so


# Delete Wakelock.sh 
rm -f /magisk/phh/su.d/wakelock*
rm -f /su/su.d/wakelock*
rm -f /system/su.d/wakelock*
rm -f /system/etc/init.d/wakelock*


