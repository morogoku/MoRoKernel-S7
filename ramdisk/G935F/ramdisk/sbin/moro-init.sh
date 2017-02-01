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


# Mount
$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,rw /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,rw /;


#-------------------------
# SYNAPSE
#-------------------------
    
    $BB chmod -R 755 /res/*;
    $BB ln -fs /res/synapse/uci /sbin/uci;
    /sbin/uci


    # Make internal storage directory.
    if [ ! -d /data/.moro ]; then
	    $BB mkdir /data/.moro;
    fi;


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

    # CPU freq. values
    echo 2600000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq;
    echo 728000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq;
    echo 1586000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
    echo 442000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;

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


# Unmount
$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,ro /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,ro /;
