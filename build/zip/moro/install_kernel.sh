#!/sbin/sh
#
# MoRoKernel Flash script
#
# 


# Initialice Morokernel folder
if [ ! -d /data/.morokernel/apk ]; then
    mkdir -p -m 777 /data/.morokernel/apk 2>/dev/null
fi


# Load functions
. /tmp/moro/functions.sh


#======================================
# AROMA INIT
#======================================

set_progress 0.01

# Mount system
mount_system
ui_print "@Mount partitions"
ui_print "-- mount /system RW"
if [ $SYSTEM_ROOT == true ]; then
	ui_print "-- Device is system-as-root"
	ui_print "-- Remounting /system as /system_root"
fi


#Check device and set OS variable
set_os


set_progress 0.10
show_progress 0.25 -6000

## PATCH SYSTEM
ui_print " "
ui_print "@Patching system and vendor libs"

cd /tmp/moro
ui_print "-- Extracting"
$BB tar -Jxf gpu_libs.tar.xz
$BB tar -Jxf secure_storage.tar.xz
ui_print "-- Copying files"


# System As Root init scripts
if [ $OS == "los17" ] || [ $OS == "twQ" ]; then
	. /tmp/moro/sar_init.sh
fi


# GPU libs
#if [ "$(file_getprop /tmp/aroma/menu.prop group4)" == "opt13" ]; then
#	ui_print "-- Installing R22 GPU libs"
#	cp -rf r22_libs/. /
#elif [ "$(file_getprop /tmp/aroma/menu.prop group4)" == "opt14" ]; then
#	ui_print "-- Installing R28 GPU libs"
#	cp -rf r28_libs/. /
#fi


# Copy secure_storage libs
if [ $OS == "twOreo" ];then
	ui_print "-- secure_storage libs to /system/vendor"
	cp -rf secure/. /system/vendor
	set_perm 0 2000 0644 /system/vendor/lib/libsecure_storage.so u:object_r:system_file:s0
	set_perm 0 2000 0644 /system/vendor/lib/libsecure_storage_jni.so u:object_r:system_file:s0
	set_perm 0 2000 0644 /system/vendor/lib64/libsecure_storage.so u:object_r:system_file:s0
	set_perm 0 2000 0644 /system/vendor/lib64/libsecure_storage_jni.so u:object_r:system_file:s0
fi



set_progress 0.35
show_progress 0.25 -24000

## FLASH KERNEL
ui_print " "
ui_print "@Flashing kernel"

cd /tmp/moro
ui_print "-- Extracting"
$BB tar -Jxf kernel.tar.xz $MODEL-$OS-$GPU-boot.img

# Write kernel img
ui_print "-- Flashing kernel $MODEL-$OS-$GPU-boot.img"
dd of=/dev/block/platform/155a0000.ufs/by-name/BOOT if=/tmp/moro/$MODEL-$OS-$GPU-boot.img
ui_print "-- Done"


set_progress 0.60

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
#if [ "$(file_getprop /tmp/aroma/menu.prop chk10)" == 1 ]; then
#	ui_print " "
#	ui_print "@Install Spectrum Profiles"
#	mkdir -p -m 777 /data/.morokernel/apk 2>/dev/null
#	cp -rf /tmp/moro/spec_profiles/. /data/.morokernel/spectrum
#fi


set_progress 0.65


#======================================
# ROOT
#======================================


ui_print " "
ui_print "@Root"
	
## WITHOUT ROOT
if [ "$(file_getprop /tmp/aroma/menu.prop group1)" == "opt1" ]; then
show_progress 0.34 -5000

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

	#cp -rf /tmp/moro/magisk/*.apk /data/.morokernel/apk

	ui_print "-- Rooting with Magisk Manager"
	ui_print " "
	$BB unzip /tmp/moro/magisk/magisk.zip META-INF/com/google/android/* -d /tmp/moro/magisk
	sh /tmp/moro/magisk/META-INF/com/google/android/update-binary dummy 1 /tmp/moro/magisk/magisk.zip

elif [ "$(file_getprop /tmp/aroma/menu.prop group1)" == "opt15" ]; then
show_progress 0.34 -19000

	if [ "$(file_getprop /tmp/aroma/menu.prop chk7)" == 1 ]; then
		ui_print "-- Clearing root data"
		clean_magisk
		sh /tmp/moro/moro_clean.sh com.topjohnwu.magisk -asd
	fi

	#cp -rf /tmp/moro/magisk/*.apk /data/.morokernel/apk

	ui_print "-- Rooting with Magisk Phh"
	ui_print " "
	$BB unzip /tmp/moro/magisk_phh/magisk.zip META-INF/com/google/android/* -d /tmp/moro/magisk_phh
	sh /tmp/moro/magisk_phh/META-INF/com/google/android/update-binary dummy 1 /tmp/moro/magisk_phh/magisk.zip
fi


ui_print " "
ui_print "@Unmounting"
unmount_system
ui_print "-- umount /system"
if [ $SYSTEM_ROOT == true ]; then
	ui_print "-- umount /system_root"
else
	ui_print "-- umount /vendor"
	umount -l /system 2>/dev/null
fi


set_progress 1.00


