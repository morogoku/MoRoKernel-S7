#!/system/bin/sh
# 
# Init MoRoKernel 2
#

LOG="/data/morokernel.log";

BB="/sbin/busybox";
RESETPROP="/sbin/resetprop -v -n"

# Mount
$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,rw /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,rw /;

(
	# tweaks
	$BB echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control
	

	# deepsleep fix
	for i in `ls /sys/class/scsi_disk/`; do
		$BB cat /sys/class/scsi_disk/$i/write_protect 2>/dev/null | grep 1 >/dev/null
		if [ $? -eq 0 ]; then
			$BB echo 'temporary none' > /sys/class/scsi_disk/$i/cache_type
		fi
	done
	
	
	# Google play services wakelock fix
	$BB echo "## -- GooglePlay wakelock fix" >> $LOG
	su -c "pm enable com.google.android.gms/.update.SystemUpdateActivity"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService$Receiver"
	su -c "pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver"
	$BB echo " " >> $LOG
	

	# Init.d support
	$BB echo "## -- Start Init.d support" >> $LOG
	if [ ! -d /system/etc/init.d ]; then
		$BB echo "## Create init.d folder" >> $LOG
	    $BB mkdir -p /system/etc/init.d;
	fi

    $BB chown -R root.root /system/etc/init.d;
	$BB chmod 777 /system/etc/init.d;
	$BB chmod 777 /system/etc/init.d/*;

    for FILE in /system/etc/init.d/*; do
		$BB echo "## Executing init.d script: $FILE" >> $LOG
		$BB sh $FILE >/dev/null;
    done;
	$BB echo "## -- End Init.d support" >> $LOG


	# Fix personalist.xml
	if [ ! -f /data/system/users/0/personalist.xml ]; then
		$BB touch /data/system/users/0/personalist.xml
		$BB chmod 600 /data/system/users/0/personalist.xml
		$BB chown system:system /data/system/users/0/personalist.xml
	fi


) 2>&1 | tee -a ./$LOG

$BB chmod 777 $LOG

# Unmount
$BB mount -t rootfs -o remount,ro rootfs;
$BB mount -o remount,ro /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,ro /;

