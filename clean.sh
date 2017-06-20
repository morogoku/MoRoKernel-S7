#!/bin/bash
#Cleaning Script written by djb77

# Clean Build Data
make clean
make ARCH=arm64 distclean

rm -f ./build.log

# Remove Created Ramdisk Files
rm -f $PWD/ramdisk/G930F/image-new.img
rm -f $PWD/ramdisk/G930F/ramdisk-new.cpio.gz
rm -f $PWD/ramdisk/G930F/split_img/boot.img-dtb
rm -f $PWD/ramdisk/G930F/split_img/boot.img-zImage
rm -f $PWD/ramdisk/G935F/image-new.img
rm -f $PWD/ramdisk/G935F/ramdisk-new.cpio.gz
rm -f $PWD/ramdisk/G935F/split_img/boot.img-dtb
rm -f $PWD/ramdisk/G935F/split_img/boot.img-zImage
rm -f $PWD/ramdisk/G930F_S8/image-new.img
rm -f $PWD/ramdisk/G930F_S8/ramdisk-new.cpio.gz
rm -f $PWD/ramdisk/G930F_S8/split_img/boot.img-dtb
rm -f $PWD/ramdisk/G930F_S8/split_img/boot.img-zImage
rm -f $PWD/ramdisk/G935F_S8/image-new.img
rm -f $PWD/ramdisk/G935F_S8/ramdisk-new.cpio.gz
rm -f $PWD/ramdisk/G935F_S8/split_img/boot.img-dtb
rm -f $PWD/ramdisk/G935F_S8/split_img/boot.img-zImage

# Remove Release files
rm -f $PWD/release/*.zip


# Removed Created dtb Folder
rm -rf $PWD/arch/arm64/boot/dtb

# Recreate Ramdisk Placeholders
echo "" > ramdisk/G930F/ramdisk/data/.placeholder
echo "" > ramdisk/G930F/ramdisk/dev/.placeholder
echo "" > ramdisk/G930F/ramdisk/lib/modules/.placeholder
echo "" > ramdisk/G930F/ramdisk/oem/.placeholder
echo "" > ramdisk/G930F/ramdisk/proc/.placeholder
echo "" > ramdisk/G930F/ramdisk/sys/.placeholder
echo "" > ramdisk/G930F/ramdisk/system/.placeholder
echo "" > ramdisk/G935F/ramdisk/data/.placeholder
echo "" > ramdisk/G935F/ramdisk/dev/.placeholder
echo "" > ramdisk/G935F/ramdisk/lib/modules/.placeholder
echo "" > ramdisk/G935F/ramdisk/oem/.placeholder
echo "" > ramdisk/G935F/ramdisk/proc/.placeholder
echo "" > ramdisk/G935F/ramdisk/sys/.placeholder
echo "" > ramdisk/G935F/ramdisk/system/.placeholder
echo "" > ramdisk/G930F_S8/ramdisk/data/.placeholder
echo "" > ramdisk/G930F_S8/ramdisk/dev/.placeholder
echo "" > ramdisk/G930F_S8/ramdisk/lib/modules/.placeholder
echo "" > ramdisk/G930F_S8/ramdisk/oem/.placeholder
echo "" > ramdisk/G930F_S8/ramdisk/proc/.placeholder
echo "" > ramdisk/G930F_S8/ramdisk/sys/.placeholder
echo "" > ramdisk/G930F_S8/ramdisk/system/.placeholder
echo "" > ramdisk/G935F_S8/ramdisk/data/.placeholder
echo "" > ramdisk/G935F_S8/ramdisk/dev/.placeholder
echo "" > ramdisk/G935F_S8/ramdisk/lib/modules/.placeholder
echo "" > ramdisk/G935F_S8/ramdisk/oem/.placeholder
echo "" > ramdisk/G935F_S8/ramdisk/proc/.placeholder
echo "" > ramdisk/G935F_S8/ramdisk/sys/.placeholder
echo "" > ramdisk/G935F_S8/ramdisk/system/.placeholder

