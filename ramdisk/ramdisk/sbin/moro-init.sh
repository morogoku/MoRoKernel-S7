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
# INIT.D SUPPORT
#-------------------------

    if [ ! -d /system/etc/init.d ]; then
	    $BB mkdir -p /system/etc/init.d/
	    $BB chown -R root.root /system/etc/init.d
	    $BB chmod 777 /system/etc/init.d/
	    $BB chmod 777 /system/etc/init.d/*
    fi

    for FILE in /system/etc/init.d/*; do
       $BB sh $FILE >/dev/null
    done;

#-------------------------


# Unmount
$BB mount -t rootfs -o remount,ro 
$BB mount -o remount,ro /system
$BB mount -o remount,rw /data
