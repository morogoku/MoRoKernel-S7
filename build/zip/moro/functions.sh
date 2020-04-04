#!/sbin/sh
#
# MoRoKernel init functions
#


# Functions
ui_print() { echo -n -e "ui_print $1\n"; }


file_getprop() { grep "^$2" "$1" | cut -d= -f2; }


show_progress() { echo "progress $1 $2"; }


set_progress() { echo "set_progress $1"; }


set_perm() {
    chown $1.$2 $4
    chown $1:$2 $4
    chmod $3 $4
    chcon $5 $4
}


clean_magisk() {
    rm -rf /cache/*magisk* /cache/unblock /data/*magisk* /data/cache/*magisk* /data/property/*magisk* \
    /data/Magisk.apk /data/busybox /data/custom_ramdisk_patch.sh /data/app/com.topjohnwu.magisk* \
    /data/user*/*/magisk.db /data/user*/*/com.topjohnwu.magisk /data/user*/*/.tmp.magisk.config \
    /data/adb/*magisk* /data/adb/post-fs-data.d /data/adb/service.d /data/adb/modules* 2>/dev/null
        
    if [ -f /system/addon.d/99-magisk.sh ]; then
        mount -o rw,remount /system
        rm -f /system/addon.d/99-magisk.sh
    fi
}


abort() {
    ui_print "$*";
    echo "abort=1" > /tmp/aroma/abort.prop
    exit 1;
}


unmount_system() {
    umount -l /system_root 2>/dev/null
    umount -l /system 2>/dev/null
}


mount_system() {
    # Mount system
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
    
    #SDK
    SDK="$(file_getprop /system/build.prop ro.build.version.sdk)"
    
    #TREBLE
    TREBLE="$(file_getprop /system/build.prop ro.treble.enabled)"
}


# Variables
BB=/sbin/busybox
BL=`getprop ro.bootloader`
MODEL=${BL:0:4}
MODEL1=G930
MODEL1_DESC="S7 Flat G930"
MODEL2=G935
MODEL2_DESC="S7 Edge G935"
GPU=r29
if [ $MODEL == $MODEL1 ]; then MODEL_DESC=$MODEL1_DESC; fi
if [ $MODEL == $MODEL2 ]; then MODEL_DESC=$MODEL2_DESC; fi


set_os() {
## CHECK SUPPORT, MODEL AND OS
    if [ $MODEL == $MODEL1 ] || [ $MODEL == $MODEL2 ]; then
        ui_print " "
        ui_print "@Device detected"

        ## SET OS VARIABLE
        if [ -f /vendor/lib/hw/gralloc.exynos5.so ] || [ -f /system_root/vendor/lib/hw/gralloc.exynos5.so ] && [ $TREBLE == "true" ]; then
        # If Treble Rom
            ui_print "-- $MODEL_DESC"
            if [ -f /system/framework/com.samsung.device.jar ]; then
            # If Treble UI Rom
                if [ $SDK == 28 ]; then
                    ui_print "-- Rom: TrebleUi PIE"
                    OS="trebleUi"
                elif [ $SDK == 29 ]; then
                    ui_print "-- Rom: Samsung Q"
                    OS="twQ"
                else
                    ui_print " "
                    ui_print "@** UNSUPPORTED ANDROID VERSION **"
                    abort "-- Treble UI ROM - Aborting..."
                fi
            else
            # If Treble AOSP Rom
                if [ $SDK == 28 ]; then
                    ui_print "-- Rom: Treble AOSP PIE"
                    OS="treble"
                elif [ $SDK == 29 ]; then
                    ui_print "-- Rom: Treble AOSP Q"
                    OS="treble"
                else
                    ui_print " "
                    ui_print "@** UNSUPPORTED ANDROID VERSION **"
                    abort "-- Treble AOSP ROM - Aborting..."
                fi
            fi	
	else
	# If NOT Treble
            if [ -f /system/framework/com.samsung.device.jar ]; then
            # If Samsung rom
                ui_print "-- $MODEL_DESC"
                if [ $SDK == 26 ]; then
                    ui_print "-- Rom: Samsung OREO"
                    OS="twOreo"
                elif [ $SDK == 28 ]; then
                    ui_print "-- Rom: Samsung PIE"
                    OS="twPie"
                else
                    ui_print " "
                    ui_print "@** UNSUPPORTED ANDROID VERSION **"
                    abort "-- Samsung ROM - Aborting..."
                fi
			
            else
            # If Lineage rom
                ui_print "-- $MODEL_DESC"
                if [ $SDK == 28 ]; then
                    ui_print "-- Rom: Lineage 16"
                    OS="los16"
                elif [ $SDK == 29 ]; then
                    ui_print "-- Rom: Lineage 17"
                    OS="los17" 
                else
                    ui_print " "
                    ui_print "@** UNSUPPORTED ANDROID VERSION **"
                    abort "-- Lineage ROM - Aborting..."
                fi
            fi
        fi
    else
        ui_print " "
        ui_print "@** UNSUPPORTED DEVICE! **"
        abort "-- The kernel is only for $VAR1 and $VAR2, and this device is $MODEL. Aborting..."
    fi
}







