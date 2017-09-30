#!/sbin/sh

# Install busybox
mv /tmp/moro/busybox /system/xbin/busybox
chmod 0755 /system/xbin/busybox
ln -s /system/xbin/busybox /system/bin/busybox
/system/xbin/busybox --install -s /system/xbin
