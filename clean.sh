#!/bin/bash
#Cleaning Script written by djb77

# Clean Build Data
make clean
make ARCH=arm64 distclean

# Remove Build Log
[ -f "$PWD/build.log" ] && rm -f $PWD/build.log

# Remove Created Ramdisk Files
#[ -f "$PWD/ramdisk/G930F/image-new.img" ] && rm -f $PWD/ramdisk/G930F/image-new.img
#[ -f "$PWD/ramdisk/G930F/ramdisk-new.cpio.gz" ] && rm -f $PWD/ramdisk/G930F/ramdisk-new.cpio.gz
#[ -f "$PWD/ramdisk/G930F/split_img/boot.img-dtb" ] && rm -f $PWD/ramdisk/G930F/split_img/boot.img-dtb
#[ -f "$PWD/ramdisk/G930F/split_img/boot.img-zImage" ] && rm -f $PWD/ramdisk/G930F/split_img/boot.img-zImage
[ -f "$PWD/ramdisk/G935F/image-new.img" ] && rm -f $PWD/ramdisk/G930F/image-new.img
[ -f "$PWD/ramdisk/G935F/ramdisk-new.cpio.gz" ] && rm -f $PWD/ramdisk/G935F/ramdisk-new.cpio.gz
[ -f "$PWD/ramdisk/G935F/split_img/boot.img-dtb" ] && rm -f $PWD/ramdisk/G935F/split_img/boot.img-dtb
[ -f "$PWD/ramdisk/G935F/split_img/boot.img-zImage" ] && rm -f $PWD/ramdisk/G935F/split_img/boot.img-zImage

# Remove Releasetool files
[ -f "$PWD/releasetools/zip/*.zip" ] && rm -f $PWD/releasetools/zip/*.zip
[ -f "$PWD/releasetools/tar/*.tar" ] && rm -f $PWD/releasetools/tar/*.tar

# Removed Created dtb Folder
[ -d "$PWD/arch/arm64/boot/dtb" ] && rm -rf $PWD/arch/arm64/boot/dtb

# Recreate Ramdisk Placeholders
#echo "" > ramdisk/G930F/ramdisk/data/.placeholder
#echo "" > ramdisk/G930F/ramdisk/dev/.placeholder
#echo "" > ramdisk/G930F/ramdisk/lib/modules/.placeholder
#echo "" > ramdisk/G930F/ramdisk/oem/.placeholder
#echo "" > ramdisk/G930F/ramdisk/proc/.placeholder
#echo "" > ramdisk/G930F/ramdisk/sys/.placeholder
#echo "" > ramdisk/G930F/ramdisk/system/.placeholder
echo "" > ramdisk/G935F/ramdisk/data/.placeholder
echo "" > ramdisk/G935F/ramdisk/dev/.placeholder
echo "" > ramdisk/G935F/ramdisk/lib/modules/.placeholder
echo "" > ramdisk/G935F/ramdisk/oem/.placeholder
echo "" > ramdisk/G935F/ramdisk/proc/.placeholder
echo "" > ramdisk/G935F/ramdisk/sys/.placeholder
echo "" > ramdisk/G935F/ramdisk/system/.placeholder
echo "" > ramdisk/G935F/ramdisk/su/.placeholder

# Recreate Releasetools Placeholders
echo "" > releasetools/tar/.placeholder
