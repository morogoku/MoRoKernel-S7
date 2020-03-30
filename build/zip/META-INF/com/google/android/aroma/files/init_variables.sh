#!/sbin/sh
#

==============
# MOUNT SYSTEM
==============
export SYSTEM_ROOT=false

block=/dev/block/platform/155a0000.ufs/by-name/SYSTEM
SYSTEM_MOUNT=/system
SYSTEM=$SYSTEM_MOUNT

# Try to detect system-as-root through $SYSTEM_MOUNT/init.rc like Magisk does
# Mount whatever $SYSTEM_MOUNT is, sometimes remount is necessary if mounted read-only

grep -q "$SYSTEM_MOUNT.*\sro[\s,]" /proc/mounts && mount -o remount,rw $SYSTEM_MOUNT || mount -o rw "$block" $SYSTEM_MOUNT

# Remount /system to /system_root if we have system-as-root and bind /system to /system_root/system (like Magisk does)
# For reference, check https://github.com/topjohnwu/Magisk/blob/master/scripts/util_functions.sh
if [ -f /system/init.rc ]; then
    mkdir /system_root
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


==================
## SET OS VARIABLE
==================
if [ -f /vendor/lib/hw/gralloc.exynos5.so ] || [ -f /system_root/vendor/lib/hw/gralloc.exynos5.so ]; then
# If Treble Rom
    if [ -f /system/framework/com.samsung.device.jar ]; then
    # If Treble UI Rom
        if [ $SDK == 28 ]; then
            OS="trebleUi"
        elif [ $SDK == 29 ]; then
            OS="twQ"
        fi
    else
    # If Treble AOSP Rom
        if [ $SDK == 28 ]; then
            OS="treble"
        elif [ $SDK == 29 ]; then
            OS="trebleQ"
        fi
    fi	
else
# If NOT Treble
    if [ -f /system/framework/com.samsung.device.jar ]; then
    # If Samsung rom
        if [ $SDK == 26 ]; then
            OS="twOreo"
        elif [ $SDK == 28 ]; then
            OS="twPie"
        fi
    else
    # If Lineage rom
        if [ $SDK == 28 ]; then
            OS="los16"
        elif [ $SDK == 29 ]; then
            OS="los17" 
        fi
    fi
fi


============
# MAGISK PHH
============
if [ $OS == "trebleQ" ]; then
    echo "show=1" > /tmp/aroma/magisk_phh.prop
fi


==========
# SHOW GPU
==========
if [ $OS == "twPie" ] || [ $OS == "twQ" ]; then
    echo "show=1" > /tmp/aroma/gpu_driver.prop
fi


=========
# UNMOUNT
=========
umount -l /system_root 2>/dev/null
umount -l /system 2>/dev/null



