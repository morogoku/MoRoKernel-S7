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
    /data/Magisk.apk /data/busybox /data/custom_ramdisk_patch.sh /data/adb/*magisk* \
    /data/adb/post-fs-data.d /data/adb/service.d /data/adb/modules* \
    /data/unencrypted/magisk /metadata/magisk /persist/magisk /mnt/vendor/persist/magisk 2>/dev/null
        
    if [ -f /system/addon.d/99-magisk.sh ]; then
        rm -f /system/addon.d/99-magisk.sh
    fi
}


abort() {
    ui_print "$*";
    echo "abort=1" > /tmp/aroma/abort.prop
    exit 1;
}


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
                if [ $SDK == 29 ]; then
                    ui_print "-- Rom: Samsung Q"
                    OS="twQ"
                    VENDOR="/system/vendor"
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
                    VENDOR="/vendor"
                elif [ $SDK == 29 ]; then
                    ui_print "-- Rom: Treble AOSP Q"
                    OS="treble"
                    VENDOR="/vendor"
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
                    VENDOR="/system/vendor"
                elif [ $SDK == 28 ]; then
                    ui_print "-- Rom: Samsung PIE"
                    OS="twPie"
                    VENDOR="/system/vendor"
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
                    VENDOR="/system/vendor"
                elif [ $SDK == 29 ]; then
                    ui_print "-- Rom: Lineage 17"
                    OS="los17"
                    VENDOR="/system/vendor"
                elif [ $SDK == 30 ]; then
                    ui_print "-- Rom: Lineage 18"
                    OS="los17"
                    VENDOR="/system/vendor"
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


mount_parts() {
    # Mount system
    ui_print " "
    ui_print "@Mount partitions"
    ui_print "-- mount /system"

    mount /system
    
    if [ -f /system/init.environ.rc ]; then
        ui_print "-- Device is system-as-root"
        ui_print "-- Remounting /system as /system_root"
        mkdir /system_root
        mount --move /system /system_root
        mount -o bind /system_root/system /system
    fi
    
    # Mount vendor
    if [ "$(ls /dev/block/platform/155a0000.ufs/by-name | grep 'VENDOR')" == "VENDOR" ]; then
        ui_print "-- mount /vendor"
        mount /dev/block/platform/155a0000.ufs/by-name/VENDOR /vendor
    fi
}


unmount_parts() {
    ui_print " "
    ui_print "@Unmount partitions"
    umount -l /system_root 2>/dev/null
    umount -l /system 2>/dev/null
    umount -l /vendor 2>/dev/null
}


init_variables() {
    BB=/sbin/busybox
    SDK="$(file_getprop /system/build.prop ro.build.version.sdk)"
    TREBLE="$(file_getprop /system/build.prop ro.treble.enabled)"
    BL=`getprop ro.bootloader`
    MODEL=${BL:0:4}
    GPU=r29

    case $MODEL in
    G930)
    	MODEL_DESC="S7 Flat G930"
    	;;
    G935)
    	MODEL_DESC="S7 Edge G935"
    	;;
    N935)
    	MODEL_DESC="Note FE N935"
    	;;
    N930)
    	MODEL_DESC="Note 7 N930"
    	MODEL="N935"
    	;;
    *)
    	MODEL_DESC="Unknown device: $MODEL"
    	;;
    esac

}

