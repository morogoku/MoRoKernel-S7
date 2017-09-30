#!/sbin/sh
# ========================================
# script Helios ROM
# ========================================
# Created by lyapota

# Remove
# Magisk
rm -rf /cache/magisk.log /cache/last_magisk.log /cache/magiskhide.log \
       /cache/magisk /cache/magisk_merge /cache/magisk_mount /cache/unblock \
       /data/Magisk.apk /data/magisk.img /data/magisk_merge.img /data/stock_boot.img \
       /data/busybox /data/magisk /data/custom_ramdisk_patch.sh 2>/dev/null
	   
# SU
rm -rf /data/su.img /data/stock_boot*.gz /data/supersu /supersu

	   
	   
	   

