#!/sbin/sh
#

==============
# MOUNT SYSTEM
==============
export SYSTEM_ROOT=false

block=/dev/block/platform/155a0000.ufs/by-name/SYSTEM

mount -o rw "$block" /system

if [ -f /system/init.environ.rc ]; then
    mkdir /system_root 2>/dev/null
    mount --move /system /system_root
    mount -o bind /system_root/system /system
    export SYSTEM_ROOT=true
fi

# Mount vendor
if [ $SYSTEM_ROOT == "false" ] && [ "$(ls /dev/block/platform/155a0000.ufs/by-name | grep 'VENDOR')" == "VENDOR" ]; then
    mount /dev/block/platform/155a0000.ufs/by-name/VENDOR /vendor
fi


file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

SDK="$(file_getprop /system/build.prop ro.build.version.sdk)"

TREBLE="$(file_getprop /system/build.prop ro.treble.enabled)"


==================
## SET OS VARIABLE
==================
if [ -f /vendor/lib/hw/gralloc.exynos5.so ] || [ -f /system_root/vendor/lib/hw/gralloc.exynos5.so ] && [ $TREBLE == "true" ]; then
# If Treble Rom
    if [ -f /system/framework/com.samsung.device.jar ]; then
    # If Treble UI Rom
        if [ $SDK == 29 ]; then
            OS="twQ"
            OSDESC="Samsung Q Rom"
        fi
    else
    # If Treble AOSP Rom
        if [ $SDK == 28 ]; then
            OS="treble"
            OSDESC="Treble AOSP Pie Rom"
        elif [ $SDK == 29 ]; then
            OS="trebleQ"
            OSDESC="Treble AOSP Q Rom"
        fi
    fi	
else
# If NOT Treble
    if [ -f /system/framework/com.samsung.device.jar ]; then
    # If Samsung rom
        if [ $SDK == 26 ]; then
            OS="twOreo"
            OSDESC="Samsung Oreo Rom"
        elif [ $SDK == 28 ]; then
            OS="twPie"
            OSDESC="Samsung Pie Rom"
        fi
    else
    # If Lineage rom
        if [ $SDK == 28 ]; then
            OS="los16"
            OSDESC="Lineage 16 Pie Rom"
        elif [ $SDK == 29 ]; then
            OS="los17" 
            OSDESC="Lineage 17/17.1 Q Rom"
        elif [ $SDK == 30 ]; then
            OS="los17" 
            OSDESC="Lineage 18/18.1 R Rom"
        fi
    fi
fi


# Set OS file 
echo "os=$OS" > /tmp/aroma/os.prop
echo "osdesc=$OSDESC" >> /tmp/aroma/os.prop


============
# MAGISK PHH
============
if [ $OS == "trebleQ" ]; then
    echo "show=1" > /tmp/aroma/magisk_phh.prop
fi


==========
# SHOW GPU
==========
if [ $OS == "twPie" ] || [ $OS == "twQ" ] || [ $OS == "treble" ] || [ $OS == "trebleQ" ]; then
    echo "show=1" > /tmp/aroma/gpu_driver.prop
fi


=========
# UNMOUNT
=========
umount -l /system_root 2>/dev/null
umount -l /system 2>/dev/null


