#!/system/bin/sh
# 
# Init MoRoKernel
#

LOG="/data/morokernel.log";
rm -f $LOG

BB="/sbin/busybox";
RESETPROP="/sbin/resetprop -v -n"

# Mount
$BB mount -t rootfs -o remount,rw rootfs
$BB mount -o remount,rw /system
$BB mount -o remount,rw /data
$BB mount -o remount,rw /

(

	$BB echo $(date) "MoRo-Kernel LOG" >> $LOG
	$BB echo " " >> $LOG

	# Fix safetynet flags
	$BB echo "## -- SafetyNet Flags" >> $LOG
	$RESETPROP "ro.build.fingerprint" "samsung/hero2ltexx/hero2lte:8.0.0/R16NW/G935FXXU2ERD5:user/release-keys"
	$BB echo " " >> $LOG


) 2>&1 | tee -a ./$LOG

$BB chmod 777 $LOG

# Unmount
$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system
$BB mount -o remount,rw /data
$BB mount -o remount,ro /

