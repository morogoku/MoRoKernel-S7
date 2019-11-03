#!/sbin/sh
#
# MoRoKernel Flash script
#
# 


# Load mount and init functions
. /tmp/moro/functions.sh


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
GPU=r22
if [ $MODEL == $MODEL1 ]; then MODEL_DESC=$MODEL1_DESC; fi
if [ $MODEL == $MODEL2 ]; then MODEL_DESC=$MODEL2_DESC; fi


#======================================
# AROMA INIT
#======================================

set_progress 0.01

ui_print "@Mount partitions"
ui_print "-- mount /system RW"
if [ $SYSTEM_ROOT == true ]; then
	ui_print "-- Device is system-as-root"
	ui_print "-- Remounting /system as /system_root"
fi

## CHECK SUPPORT, MODEL AND OS
if [ $MODEL == $MODEL1 ] || [ $MODEL == $MODEL2 ]; then
	ui_print " "
	ui_print "@Device detected"
	# Set OS
	if [ "$(ls /dev/block/platform/155a0000.ufs/by-name | grep 'VENDOR')" == "VENDOR" ] && [ ! -f /system/framework/com.samsung.device.jar ]; then
		# If Treble Rom
		ui_print "-- $MODEL_DESC"
		if [ $SDK == 28 ]; then
			ui_print "-- Rom: Treble PIE"
			OS="treblePie"
		elif [ $SDK == 29 ]; then
			ui_print "-- Rom: Treble Q"
			OS="treblePie"
		else
			ui_print " "
			ui_print "@** UNSUPPORTED ANDROID VERSION **"
			abort "-- This kernel is only for TREBLE PIE Rom, Aborting..."
		fi
	else
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
			# If Lineage rom
			ui_print "-- $MODEL_DESC"
			if [ $SDK == 28 ]; then
				ui_print "-- Rom: Lineage 16"
				OS="lineage16"
			elif [ $SDK == 29 ]; then
				ui_print "-- Rom: Lineage 17"
				OS="lineage17" 
			else
				ui_print " "
				ui_print "@** UNSUPPORTED ANDROID VERSION **"
				abort "-- This kernel is only for AOSP PIE Rom, Aborting..."
			fi
		fi
	fi
else
	ui_print " "
	ui_print "@** UNSUPPORTED DEVICE! **"
	abort "-- The kernel is only for $VAR1 and $VAR2, and this device is $MODEL. Aborting..."
fi


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

# GPU libs
if [ $OS == "treblePie" ];then
	GPU=r28
else
	# GPU libs
	if [ "$(file_getprop /tmp/aroma/gpu.prop selected.1)" == 1 ]; then
		ui_print "-- r22 GPU Driver & libs"
		cp -rf r22_libs/. /
	fi
	if [ "$(file_getprop /tmp/aroma/gpu.prop selected.1)" == 2 ]; then
		ui_print "-- r28 GPU Driver & libs"
		GPU=r28
		cp -rf r28_libs/. /
	fi


	# Copy secure_storage libs
	if [ $OS == "twOreo" ];then
		ui_print "-- secure_storage libs to /system/vendor"
		cp -rf secure/. /system/vendor
		set_perm 0 2000 0644 /system/vendor/lib/libsecure_storage.so u:object_r:system_file:s0
		set_perm 0 2000 0644 /system/vendor/lib/libsecure_storage_jni.so u:object_r:system_file:s0
		set_perm 0 2000 0644 /system/vendor/lib64/libsecure_storage.so u:object_r:system_file:s0
		set_perm 0 2000 0644 /system/vendor/lib64/libsecure_storage_jni.so u:object_r:system_file:s0
	fi
fi

# REMOVE RO.LMK... FROM BUILD.PROP
sed -i '/ro.lmk/d' /system/build.prop


set_progress 0.35
show_progress 0.25 -24000

## FLASH KERNEL
ui_print " "
ui_print "@Flashing kernel"

cd /tmp/moro
ui_print "-- Extracting"
$BB tar -Jxf kernel.tar.xz $MODEL-$OS-$GPU-boot.img

## Little OC
if [ "$(file_getprop /tmp/aroma/menu.prop group3)" == "opt4" ]; then
	# Unpack
	ui_print "-- Unpacking"
	mv /tmp/moro/$MODEL-$OS-$GPU-boot.img /tmp/moro/aik/boot.img
	cd /tmp/moro/aik
	./unpackimg.sh boot.img
	rm -f boot.img
	
	# Patch cmdline
	ui_print "-- Enabling Little CPU OC"
	. /tmp/moro/cmdline.sh
	
	# Pack
	ui_print "-- Packing"
	cd /tmp/moro/aik
	./repackimg.sh
	echo SEANDROIDENFORCE >> image-new.img
	mv -f /tmp/moro/aik/image-new.img /tmp/moro/$MODEL-$OS-$GPU-boot.img
	cd /tmp/moro
fi

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
if [ "$(file_getprop /tmp/aroma/menu.prop chk10)" == 1 ]; then
	ui_print " "
	ui_print "@Install Spectrum Profiles"
	mkdir -p /data/media/0/Spectrum/profiles 2>/dev/null;
	cp -rf /tmp/moro/spec_profiles/. /data/media/0/Spectrum/profiles/
fi


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

	cp -rf /tmp/moro/magisk/*.apk /data/.morokernel/apk

	ui_print "-- Rooting with Magisk Manager"
	ui_print " "
	$BB unzip /tmp/moro/magisk/magisk.zip META-INF/com/google/android/* -d /tmp/moro/magisk
	sh /tmp/moro/magisk/META-INF/com/google/android/update-binary dummy 1 /tmp/moro/magisk/magisk.zip
fi


ui_print " "
ui_print "@Unmounting"
unmount_system
ui_print "-- umount /system"
if [ $SYSTEM_ROOT == true ]; then
	ui_print "-- umount /system_root"
fi

set_progress 1.00


