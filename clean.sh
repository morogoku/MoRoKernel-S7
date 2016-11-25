#!/bin/bash
#Cleaning Script written by djb77

# Clean Build Data
make clean
make ARCH=arm64 distclean

# Remove Build Log
rm -f $PWD/build.log

# Remove Created Ramdisk Files
rm -f $PWD/ramdisk/image-new.img
rm -f $PWD/ramdisk/ramdisk-new.cpio.gz
rm -f $PWD/ramdisk/split_img/boot.img-dtb
rm -f $PWD/ramdisk/split_img/boot.img-zImage

# Remove Releasetool files
rm -f $PWD/release/zip/*.zip
rm -f $PWD/release/tar/*.tar

# Removed Created dtb Folder
rm -rf $PWD/arch/arm64/boot/dtb

# Recreate Ramdisk Placeholders
echo "" > ramdisk/ramdisk/data/.placeholder
echo "" > ramdisk/ramdisk/dev/.placeholder
echo "" > ramdisk/ramdisk/lib/modules/.placeholder
echo "" > ramdisk/ramdisk/oem/.placeholder
echo "" > ramdisk/ramdisk/proc/.placeholder
echo "" > ramdisk/ramdisk/sys/.placeholder
echo "" > ramdisk/ramdisk/system/.placeholder

# Recreate Releasetools Placeholders
echo "" > release/tar/.placeholder
