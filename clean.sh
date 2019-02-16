#!/bin/bash
#
# Thanks to djb77 
#
# MoRoKernel Cleaning Script 1.0
#

# Clean Build Data
make clean
make ARCH=arm64 distclean

rm -f ./*.log



# Remove Release files
rm -f $PWD/build/*.zip
rm -rf $PWD/build/temp
rm -rf $PWD/build/kernel-temp
rm -f $PWD/arch/arm64/configs/tmp_defconfig
rm -f $PWD/build/zip/common/moro/kernel.tar.xz
rm -f $PWD/.wireguard-fetch-lock


# Removed Created dtb Folder
rm -rf $PWD/arch/arm64/boot/dtb


# Recreate Ramdisk Placeholders
echo "" > build/ramdisk/tw/ramdisk/acct/.placeholder
echo "" > build/ramdisk/tw/ramdisk/cache/.placeholder
echo "" > build/ramdisk/tw/ramdisk/config/.placeholder
echo "" > build/ramdisk/tw/ramdisk/data/.placeholder
echo "" > build/ramdisk/tw/ramdisk/dev/.placeholder
echo "" > build/ramdisk/tw/ramdisk/lib/modules/.placeholder
echo "" > build/ramdisk/tw/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/tw/ramdisk/proc/.placeholder
echo "" > build/ramdisk/tw/ramdisk/storage/.placeholder
echo "" > build/ramdisk/tw/ramdisk/sys/.placeholder
echo "" > build/ramdisk/tw/ramdisk/system/.placeholder

echo "" > build/ramdisk/lin15/acct/.placeholder
echo "" > build/ramdisk/lin15/config/.placeholder
echo "" > build/ramdisk/lin15/data/.placeholder
echo "" > build/ramdisk/lin15/dev/.placeholder
echo "" > build/ramdisk/lin15/mnt/.placeholder
echo "" > build/ramdisk/lin15/oem/.placeholder
echo "" > build/ramdisk/lin15/proc/.placeholder
echo "" > build/ramdisk/lin15/storage/.placeholder
echo "" > build/ramdisk/lin15/sys/.placeholder
echo "" > build/ramdisk/lin15/system/.placeholder

echo "" > build/ramdisk/lin16/acct/.placeholder
echo "" > build/ramdisk/lin16/config/.placeholder
echo "" > build/ramdisk/lin16/data/.placeholder
echo "" > build/ramdisk/lin16/dev/.placeholder
echo "" > build/ramdisk/lin16/mnt/.placeholder
echo "" > build/ramdisk/lin16/oem/.placeholder
echo "" > build/ramdisk/lin16/proc/.placeholder
echo "" > build/ramdisk/lin16/storage/.placeholder
echo "" > build/ramdisk/lin16/sys/.placeholder
echo "" > build/ramdisk/lin16/system/.placeholder


