#!/system/bin/sh
# 
# Init MoRoKernel
#

# Busybox 
if [ -e /su/xbin/busybox ]; then
	BB=/su/xbin/busybox;
else if [ -e /sbin/busybox ]; then
	BB=/sbin/busybox;
else
	BB=/system/xbin/busybox;
fi;
fi;

# Define logfile path
MORO_LOGFILE="/data/moro-kernel.log"

# maintain log file history
$BB rm $MORO_LOGFILE.3
$BB mv $MORO_LOGFILE.2 $MORO_LOGFILE.3
$BB mv $MORO_LOGFILE.1 $MORO_LOGFILE.2
$BB mv $MORO_LOGFILE $MORO_LOGFILE.1

# Initialize the log file (chmod to make it readable also via /sdcard link)
$BB echo $(date) "MoRo-Kernel initialisation started" > $MORO_LOGFILE
$BB chmod 777 $MORO_LOGFILE
$BB cat /proc/version >> $MORO_LOGFILE
$BB echo "=========================" >> $MORO_LOGFILE
$BB grep ro.build.version /system/build.prop >> $MORO_LOGFILE
$BB echo "=========================" >> $MORO_LOGFILE


# Mount
$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,rw /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,rw /;

#-------------------------
# FAKE KNOX 0
#-------------------------

/sbin/resetprop -v -n ro.boot.warranty_bit "0"
/sbin/resetprop -v -n ro.warranty_bit "0"
$BB echo $(date) "Enabled Fake Knox 0" >> $MORO_LOGFILE


#-------------------------
# FLAGS FOR SAFETYNET
#-------------------------

/sbin/resetprop -n ro.boot.veritymode "enforcing"
/sbin/resetprop -n ro.boot.verifiedbootstate "green"
/sbin/resetprop -n ro.boot.flash.locked "1"
/sbin/resetprop -n ro.boot.ddrinfo "00000001"
$BB echo $(date) "Enabled Flags for safety net" >> $MORO_LOGFILE


#-------------------------
# TWEAKS
#-------------------------

    # SD-Card Readhead
    $BB echo "2048" > /sys/devices/virtual/bdi/179:0/read_ahead_kb;

    # Internet Speed
    $BB echo "0" > /proc/sys/net/ipv4/tcp_timestamps;
    $BB echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse;
    $BB echo "1" > /proc/sys/net/ipv4/tcp_sack;
    $BB echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle;
    $BB echo "1" > /proc/sys/net/ipv4/tcp_window_scaling;
    $BB echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes;
    $BB echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl;
    $BB echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout;
    $BB echo "404480" > /proc/sys/net/core/wmem_max;
    $BB echo "404480" > /proc/sys/net/core/rmem_max;
    $BB echo "256960" > /proc/sys/net/core/rmem_default;
    $BB echo "256960" > /proc/sys/net/core/wmem_default;
    $BB echo "4096,16384,404480" > /proc/sys/net/ipv4/tcp_wmem;
    $BB echo "4096,87380,404480" > /proc/sys/net/ipv4/tcp_rmem;

$BB echo $(date) "Enabled tweaks" >> $MORO_LOGFILE


#-------------------------
# KERNEL INIT VALUES
#-------------------------

    


#-------------------------


# Unmount
$BB mount -t rootfs -o remount,ro rootfs;
$BB mount -o remount,ro /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,ro /;
