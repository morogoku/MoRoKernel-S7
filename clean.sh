#!/bin/bash
#
# Thanks to djb77 
#
# MoRoKernel Cleaning Script 1.0
#

# Clean Build Data
make clean
make ARCH=arm64 distclean

rm -f ./Edge_build.log
rm -f ./Flat_build.log



# Remove Release files
rm -f $PWD/build/*.zip
rm -rf $PWD/build/temp
rm -rf $PWD/build/temp2
rm -f $PWD/arch/arm64/configs/tmp_defconfig


# Removed Created dtb Folder
rm -rf $PWD/arch/arm64/boot/dtb


# Recreate Ramdisk Placeholders
echo "" > build/ramdisk/ramdisk/acct/.placeholder
echo "" > build/ramdisk/ramdisk/cache/.placeholder
echo "" > build/ramdisk/ramdisk/config/.placeholder
echo "" > build/ramdisk/ramdisk/data/.placeholder
echo "" > build/ramdisk/ramdisk/dev/.placeholder
echo "" > build/ramdisk/ramdisk/lib/modules/.placeholder
echo "" > build/ramdisk/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/ramdisk/proc/.placeholder
echo "" > build/ramdisk/ramdisk/storage/.placeholder
echo "" > build/ramdisk/ramdisk/sys/.placeholder
echo "" > build/ramdisk/ramdisk/system/.placeholder


