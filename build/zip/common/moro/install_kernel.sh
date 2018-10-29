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

clean_supersu() {
	rm -rf /data/su.img /data/stock_boot*.gz /data/supersu /data/.supersu /supersu /data/adb/su
}

clean_magisk() {
	rm -rf /cache/*magisk* /cache/unblock /data/*magisk* /data/cache/*magisk* /data/property/*magisk* \
        /data/Magisk.apk /data/busybox /data/custom_ramdisk_patch.sh /data/app/com.topjohnwu.magisk* \
        /data/user*/*/magisk.db /data/user*/*/com.topjohnwu.magisk /data/user*/*/.tmp.magisk.config \
        /data/adb/*magisk* 2>/dev/null
}

abort() {
	ui_print "$*";
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
	if [ -f /system/framework/samsung-services.jar ]; then
		OS="tw"
		ui_print "-- $MODEL_DESC"
		ui_print "-- Rom: Samsung"
	else
		OS="aosp"
		# Set Lineage version
		if [ $SDK == 27 ]; then
			LIN="lin15"
			OS_VERSION="8.1.0"
			ui_print "-- $MODEL_DESC"
			ui_print "-- Rom: Linege 15.1"
		elif [ $SDK == 28 ]; then
			LIN="lin16"
			OS_VERSION="9.0.0"
			ui_print "-- $MODEL_DESC"
			ui_print "-- Rom: Lineage 16"
		else
			abort "-- Lineage version not supported, Aborting..."
		fi
	fi
else
	ui_print " "
	ui_print "@** UNSUPPROTED DEVICE! **"
	abort "-- The kernel is only for $VAR1 and $VAR2, and this device is $MODEL. Aborting..."
fi


set_progress 0.10
show_progress 0.25 -4000

## FLASH KERNEL
ui_print " "
ui_print "@Flashing kernel"
if [ $OS == "tw" ]; then
	cd /tmp/moro
	ui_print "-- Extracting"
	$BB tar -Jxf kernel.tar.xz $MODEL-$OS-boot.img
	ui_print "-- Flashing kernel $MODEL-$OS-boot.img"
	dd of=/dev/block/platform/155a0000.ufs/by-name/BOOT if=/tmp/moro/$MODEL-$OS-boot.img
	ui_print "-- Done"
fi
if [ $OS == "aosp" ]; then
	mkdir /tmp/moro/ramdisk
	cd /tmp/moro
	ui_print "-- Extracting"
	$BB tar -Jxf kernel.tar.xz $MODEL-$OS-zImage $MODEL-$OS-dtb
	$BB tar -Jxf ramdisk.tar.xz $MODEL-$LIN-ramdisk.cpio

	cd ramdisk
	cpio -idv < ../$MODEL-$LIN-ramdisk.cpio
	rm -f /tmp/moro/$MODEL-$LIN-ramdisk.cpio
	find . | cpio -H newc -o | gzip -9 > ../$MODEL-$LIN-ramdisk.cpio.gz

	cd /tmp/moro
	./mkbootimg --kernel $MODEL-$OS-zImage --ramdisk $MODEL-$LIN-ramdisk.cpio.gz --base 0x10000000 --pagesize 2048 --dt $MODEL-$OS-dtb --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --second_offset 0x00f00000 --tags_offset 0x00000100 --os_patch_level 2019-02 --os_version $OS_VERSION --hash sha1 -o $MODEL-$LIN-boot.img
	
	echo SEANDROIDENFORCE >> $MODEL-$LIN-boot.img
	cp $MODEL-$LIN-boot.img /sdcard/test

	ui_print "-- Flashing kernel $MODEL-$LIN-boot.img"
	dd of=/dev/block/platform/155a0000.ufs/by-name/BOOT if=/tmp/moro/$MODEL-$LIN-boot.img
	ui_print "-- Done"
fi


set_progress 0.35

## PATCH SYSTEM
if [ $OS == "tw" ]; then
	ui_print " "
	ui_print "@Patching system and vendor libs"
	cp -rf system/. /system
	
	# Clean wakelock scripts
	rm -f /magisk/phh/su.d/wakelock*
	rm -f /data/adb/su/su.d/wakelock*
	rm -f /system/su.d/wakelock*
	rm -f /system/etc/init.d/wakelock*
fi

set_progress 0.40

#======================================
# OPTIONS
#======================================


## FIX PRIVATE MODE
if [ "$(file_getprop /tmp/aroma/menu.prop chk9)" == 1 ]; then
	ui_print " "
	ui_print "@Fix Private Mode"
	rm -f /data/system/users/privatemode*
	sh /tmp/moro/moro_clean.sh com.samsung.android.personalpage.service -asd
	cp -rf /tmp/moro/private_mode/. /system
fi


## MTWEAKS
if [ "$(file_getprop /tmp/aroma/menu.prop chk2)" == 1 ]; then
	ui_print " "
	ui_print "@MTWeaks App"
	sh /tmp/moro/moro_clean.sh com.moro.mtweaks -as
	cp -rf /tmp/moro/mtweaks/. /data/.morokernel/apk
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

## FLASH RECOVERY
if [ "$(file_getprop /tmp/aroma/menu.prop chk8)" == 1 ]; then
	ui_print " "
	ui_print "@Flashing patched recovery TWRP 3.2.3-0 by Tkkg1994"
	ui_print "-- Extracting"
	$BB tar -Jxf recovery.tar.xz $MODEL-recovery.img
	ui_print "-- Flashing recovery $MODEL-recovery.img"
	dd of=/dev/block/platform/155a0000.ufs/by-name/RECOVERY if=/tmp/moro/$MODEL-recovery.img
	ui_print "-- Done"
fi


## PERMISSIONS
if [ $OS == "tw" ]; then
	ui_print " "
	ui_print "@Setting Permissions"
	set_perm 0 2000 0644 /system/vendor/lib/libsecure_storage.so u:object_r:system_file:s0
	set_perm 0 2000 0644 /system/vendor/lib64/libsecure_storage.so u:object_r:system_file:s0
	set_perm 0 2000 0644 /system/vendor/lib/egl/libGLES_mali.so u:object_r:system_file:s0
	set_perm 0 2000 0644 /system/vendor/lib64/egl/libGLES_mali.so u:object_r:system_file:s0
	set_perm 0 0 0644 /system/priv-app/PersonalPageService/* u:object_r:system_file:s0
fi


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
		clean_supersu
		clean_magisk
		sh /tmp/moro/moro_clean.sh eu.chainfire.supersu -asd
		sh /tmp/moro/moro_clean.sh eu.chainfire.suhide -asd
		sh /tmp/moro/moro_clean.sh com.topjohnwu.magisk -asd
	fi
fi


## MAGISK ROOT
if [ "$(file_getprop /tmp/aroma/menu.prop group1)" == "opt2" ]; then
show_progress 0.34 -19000

	# Clean opposite kernel
	clean_supersu
	sh /tmp/moro/moro_clean.sh eu.chainfire.supersu -asd
	sh /tmp/moro/moro_clean.sh eu.chainfire.suhide -asd

	if [ "$(file_getprop /tmp/aroma/menu.prop chk7)" == 1 ]; then
		ui_print "-- Clearing root data"
		clean_magisk
		sh /tmp/moro/moro_clean.sh com.topjohnwu.magisk -asd
	fi

	# Install apk
	cp -rf /tmp/moro/magisk/magisk.apk /data/.morokernel/apk

	ui_print "-- Rooting with Magisk Manager"
	ui_print " "
	$BB unzip /tmp/moro/magisk/magisk.zip META-INF/com/google/android/* -d /tmp/moro/magisk
	sh /tmp/moro/magisk/META-INF/com/google/android/update-binary dummy 1 /tmp/moro/magisk/magisk.zip
fi


# SUPERSU ROOT
if [ "$(file_getprop /tmp/aroma/menu.prop group1)" == "opt3" ]; then
show_progress 0.34 -34000

	# Clean opposite kernel
	clean_magisk
	sh /tmp/moro/moro_clean.sh com.topjohnwu.magisk -asd

	if [ "$(file_getprop /tmp/aroma/menu.prop chk7)" == 1 ]; then
		ui_print "-- Clearing root data"
		clean_supersu
		sh /tmp/moro/moro_clean.sh eu.chainfire.supersu -asd
		sh /tmp/moro/moro_clean.sh eu.chainfire.suhide -asd
	fi

	rm -f /data/.supersu
	echo "SYSTEMLESS=true" >> /data/.supersu
	echo "BINDSBIN=true" >> /data/.supersu

	# Install apk
	cp -rf /tmp/moro/supersu/superuser.apk /data/.morokernel/apk

	ui_print "-- Rooting with SuperSU" 
	$BB unzip /tmp/moro/supersu/supersu.zip META-INF/com/google/android/* -d /tmp/moro/supersu
	sh /tmp/moro/supersu/META-INF/com/google/android/update-binary dummy 1 /tmp/moro/supersu/supersu.zip

	ui_print " "
	ui_print "-- Suhide"
	$BB unzip /tmp/moro/suhide/suhide.zip META-INF/com/google/android/* -d /tmp/moro/suhide
	sh /tmp/moro/suhide/META-INF/com/google/android/update-binary dummy 1 /tmp/moro/suhide/suhide.zip
fi

set_progress 1.00


