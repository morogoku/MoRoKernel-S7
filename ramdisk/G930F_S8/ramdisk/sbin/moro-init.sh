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

DATA_PATH=/data/.moro
MTWEAKS_PATH=/data/.mtweaks


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


#-------------------------
# FLAGS FOR SAFETYNET
#-------------------------

/sbin/resetprop -n ro.boot.veritymode "enforcing"
/sbin/resetprop -n ro.boot.verifiedbootstate "green"
/sbin/resetprop -n ro.boot.flash.locked "1"
/sbin/resetprop -n ro.boot.ddrinfo "00000001"


#-------------------------
# SYNAPSE
#-------------------------
    
    $BB chmod -R 755 /res/*;
    $BB ln -fs /res/synapse/uci /sbin/uci;
    /sbin/uci


	# Make internal storage directory.
    if [ ! -d $DATA_PATH ]; then
	    $BB mkdir $DATA_PATH;
    fi;

	$BB chmod 0777 $DATA_PATH;
	$BB chown 0.0 $DATA_PATH;

	# Delete backup directory
	$BB rm -rf $DATA_PATH/bk;

    # Make backup directory.
	$BB mkdir $DATA_PATH/bk;
	$BB chmod 0777 $DATA_PATH/bk;
	$BB chown 0.0 $DATA_PATH/bk;

	# Save original voltages
	$BB cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster1_volt_table > $DATA_PATH/bk/bk_orig_cl1_voltage
	$BB cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster0_volt_table > $DATA_PATH/bk/bk_orig_cl0_voltage
	$BB chmod -R 755 $DATA_PATH/bk/*;
	

#-------------------------
# MTWEAKS
#-------------------------

	# Make internal storage directory.
    if [ ! -d $MTWEAKS_PATH ]; then
	    $BB mkdir $MTWEAKS_PATH;
    fi;
	
	$BB chmod 0777 $MTWEAKS_PATH;
	$BB chown 0.0 $MTWEAKS_PATH;

	# Delete backup directory
	$BB rm -rf $MTWEAKS_PATH/bk;

    # Make backup directory.
	$BB mkdir $MTWEAKS_PATH/bk;
	$BB chmod 0777 $MTWEAKS_PATH/bk;
	$BB chown 0.0 $MTWEAKS_PATH/bk;

	# Save original voltages
	$BB cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster1_volt_table > $MTWEAKS_PATH/bk/cpuCl1_stock_voltage
	$BB cat /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster0_volt_table > $MTWEAKS_PATH/bk/cpuCl0_stock_voltage
	$BB cat /sys/devices/14ac0000.mali/volt_table > $MTWEAKS_PATH/bk/gpu_stock_voltage
	$BB chmod -R 755 $MTWEAKS_PATH/bk/*;
	
	
#-------------------------
# TWEAKS
#-------------------------

    # SD-Card Readhead
    echo "2048" > /sys/devices/virtual/bdi/179:0/read_ahead_kb;

    # Internet Speed
    echo "0" > /proc/sys/net/ipv4/tcp_timestamps;
    echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse;
    echo "1" > /proc/sys/net/ipv4/tcp_sack;
    echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle;
    echo "1" > /proc/sys/net/ipv4/tcp_window_scaling;
    echo "5" > /proc/sys/net/ipv4/tcp_keepalive_probes;
    echo "30" > /proc/sys/net/ipv4/tcp_keepalive_intvl;
    echo "30" > /proc/sys/net/ipv4/tcp_fin_timeout;
    echo "404480" > /proc/sys/net/core/wmem_max;
    echo "404480" > /proc/sys/net/core/rmem_max;
    echo "256960" > /proc/sys/net/core/rmem_default;
    echo "256960" > /proc/sys/net/core/wmem_default;
    echo "4096,16384,404480" > /proc/sys/net/ipv4/tcp_wmem;
    echo "4096,87380,404480" > /proc/sys/net/ipv4/tcp_rmem;


#-------------------------
# KERNEL INIT VALUES
#-------------------------

    # Led Fade-out
    echo 700 > /sys/class/sec/led/led_notification_ramp_down;


#-------------------------
# INIT.D SUPPORT
#-------------------------

    if [ ! -d /system/etc/init.d ]; then
	    $BB mkdir -p /system/etc/init.d;
	fi

    $BB chown -R root.root /system/etc/init.d;
	$BB chmod 777 /system/etc/init.d;
	$BB chmod 777 /system/etc/init.d/*

    for FILE in /system/etc/init.d/*; do
       $BB sh $FILE >/dev/null;
    done;


#-------------------------
# APPLY PERMISSIONS
#-------------------------

	# sqlite3
	$BB chown 0.0 /system/xbin/sqlite3;
	$BB chmod 755 /system/xbin/sqlite3;

	# Fix SafetyNet by Repulsa
	$BB chmod 640 /sys/fs/selinux/enforce

#-------------------------


# Unmount
$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,ro /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,ro /;
