#!/system/bin/sh
# 
# Init MoRoKernel
#

# Busybox
BB=/system/xbin/busybox


# Mount
$BB mount -t rootfs -o remount,rw
$BB mount -o remount,rw /system
$BB mount -o remount,rw /data/


# init.d support
if [ ! -d /system/etc/init.d ]; then
	$BB mkdir -p /system/etc/init.d/
	$BB chown -R root.root /system/etc/init.d
	$BB chmod 777 /system/etc/init.d/
	$BB chmod 777 /system/etc/init.d/*
fi

# start init.d
for FILE in /system/etc/init.d/*; do
   $BB sh $FILE >/dev/null
done;


# Unmount
$BB mount -t rootfs -o remount,ro 
$BB mount -o remount,ro /system
$BB mount -o remount,rw /data
