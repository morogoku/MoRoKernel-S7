#!/sbin/sh
#
# MoRoKernel Flash script 2.0
#
# Credit also goes to @djb77
# @lyapota, @Tkkg1994, @osm0sis
# @dwander for bits of code
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
        /data/adb/*magisk* 2>/dev/null
}

abort() {
	ui_print "$*";
	echo "abort=1" > /tmp/aroma/abort.prop
	exit 1;
}


# Initialice Morokernel folder
mkdir -p -m 777 /data/.morokernel/apk 2>/dev/null


# Variables
BB=/sbin/busybox
SDK="$(file_getprop /system/build.prop ro.build.version.sdk)"
BL=`getprop ro.bootloader`
MODEL=${BL:0:4}
MODEL1=G930
MODEL1_DESC="S7 Flat G930"
MODEL2=G935
MODEL2_DESC="S7 Edge G935"
if [ $MODEL == $MODEL1 ]; then MODEL_DESC=$MODEL1_DESC; fi
if [ $MODEL == $MODEL2 ]; then MODEL_DESC=$MODEL2_DESC; fi



#======================================
# AROMA INIT
#======================================

set_progress 0.01

## CHECK SUPPORT, MODEL AND OS
if [ $MODEL == $MODEL1 ] || [ $MODEL == $MODEL2 ]; then
	ui_print " "
	ui_print "@Device detected"
	# Set OS
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
			abort "-- This kernel is only for Samsung OREO Rom, Aborting..."
		fi
		
	else
		# If AOSP rom
		if [ $SDK == 28 ]; then
			ui_print "-- Rom: AOSP PIE"
			OS="aospPie"
		else
			ui_print " "
			ui_print "@** UNSUPPORTED ANDROID VERSION **"
			abort "-- This kernel is only for AOSP PIE Rom, Aborting..."
		fi
	fi
else
	ui_print " "
	ui_print "@** UNSUPPORTED DEVICE! **"
	abort "-- The kernel is only for $VAR1 and $VAR2, and this device is $MODEL. Aborting..."
fi



set_progress 0.10
show_progress 0.25 -4000

## FLASH KERNEL
ui_print " "
ui_print "@Flashing kernel"

cd /tmp/moro
ui_print "-- Extracting"
$BB tar -Jxf kernel.tar.xz $MODEL-$OS-boot.img
ui_print "-- Flashing kernel $MODEL-$OS-boot.img"
dd of=/dev/block/platform/155a0000.ufs/by-name/BOOT if=/tmp/moro/$MODEL-$OS-boot.img
ui_print "-- Done"


set_progress 0.35


## PATCH SYSTEM
ui_print " "
ui_print "@Patching system and vendor libs"

ui_print "-- Extracting"
$BB tar -Jxf r22_libs.tar.xz
$BB tar -Jxf secure_storage.tar.xz
ui_print "-- Copying files"

# GPU libs
ui_print "-- r22 GPU libs"
cp -rf libs/. /

# Copy secure_storage libs
if [ $OS == "twOreo" ];then
	ui_print "-- secure_storage libs to /system/vendor"
	cp -rf secure/. /system/vendor
else
	ui_print "-- secure_storage libs to /system"
	cp -rf secure/. /system/
fi


set_progress 0.40

#======================================
# OPTIONS
#======================================


## MTWEAKS
if [ "$(file_getprop /tmp/aroma/menu.prop chk2)" == 1 ]; then
	ui_print " "
	ui_print "@MTWeaks App"
	sh /tmp/moro/moro_clean.sh com.moro.mtweaks -as
	cp -rf /tmp/moro/mtweaks/*.apk /data/.morokernel/apk
fi

## SPECTRUM PROFILES
if [ "$(file_getprop /tmp/aroma/menu.prop chk10)" == 1 ]; then
	ui_print " "
	ui_print "@Install Spectrum Profiles"
	mkdir -p /data/media/0/Spectrum/profiles 2>/dev/null;
	cp -rf /tmp/moro/spec_profiles/. /data/media/0/Spectrum/profiles/
fi


set_progress 0.45
show_progress 0.25 -5000

## PERMISSIONS
ui_print " "
ui_print "@Setting Permissions"
set_perm 0 2000 0644 /system/vendor/lib/libsecure_storage.so u:object_r:system_file:s0
set_perm 0 2000 0644 /system/vendor/lib/libsecure_storage_jni.so u:object_r:system_file:s0
set_perm 0 2000 0644 /system/vendor/lib64/libsecure_storage.so u:object_r:system_file:s0
set_perm 0 2000 0644 /system/vendor/lib64/libsecure_storage_jni.so u:object_r:system_file:s0


set_progress 0.65

#======================================
# ROOT
#======================================


ui_print " "
ui_print "@Root"
	
## WITHOUT ROOT
if [ "$(file_getprop /tmp/aroma/menu.prop group1)" == "opt1" ]; then
	ui_print "-- Without Root"
	if [ "$(file_getprop /tmp/aroma/menu.prop chk7)" == 1 ]; then
		ui_print "-- Clear root data"
		clean_magisk
		sh /tmp/moro/moro_clean.sh com.topjohnwu.magisk -asd
	fi
fi


## MAGISK ROOT
if [ "$(file_getprop /tmp/aroma/menu.prop group1)" == "opt2" ]; then
show_progress 0.34 -19000

	if [ "$(file_getprop /tmp/aroma/menu.prop chk7)" == 1 ]; then
		ui_print "-- Clearing root data"
		clean_magisk
		sh /tmp/moro/moro_clean.sh com.topjohnwu.magisk -asd
	fi

	cp -rf /tmp/moro/magisk/*.apk /data/.morokernel/apk

	ui_print "-- Rooting with Magisk Manager"
	ui_print " "
	$BB unzip /tmp/moro/magisk/magisk.zip META-INF/com/google/android/* -d /tmp/moro/magisk
	sh /tmp/moro/magisk/META-INF/com/google/android/update-binary dummy 1 /tmp/moro/magisk/magisk.zip
fi


set_progress 1.00


