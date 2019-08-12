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
rm -f $PWD/build/*.zip 2>/dev/null
rm -rf $PWD/build/temp 2>/dev/null
rm -rf $PWD/build/kernel-temp 2>/dev/null
rm -f $PWD/arch/arm64/configs/tmp_defconfig 2>/dev/null
rm -f $PWD/build/zip/common/moro/kernel.tar.xz 2>/dev/null
rm -rf $PWD/net/wireguard 2>/dev/null
rm -r $PWD/arch/arm64/boot/dts/*.dtb 2>/dev/null
rm -f $PWD/.wireguard-fetch-lock 2>/dev/null


# Removed Created dtb Folder
rm -rf $PWD/arch/arm64/boot/dtb 2>/dev/null


# Recreate Ramdisk Placeholders
echo "" > build/ramdisk/twOreo/acct/.placeholder
echo "" > build/ramdisk/twOreo/cache/.placeholder
echo "" > build/ramdisk/twOreo/config/.placeholder
echo "" > build/ramdisk/twOreo/data/.placeholder
echo "" > build/ramdisk/twOreo/dev/.placeholder
echo "" > build/ramdisk/twOreo/lib/modules/.placeholder
echo "" > build/ramdisk/twOreo/mnt/.placeholder
echo "" > build/ramdisk/twOreo/proc/.placeholder
echo "" > build/ramdisk/twOreo/storage/.placeholder
echo "" > build/ramdisk/twOreo/sys/.placeholder
echo "" > build/ramdisk/twOreo/system/.placeholder

echo "" > build/ramdisk/twPie/acct/.placeholder
echo "" > build/ramdisk/twPie/cache/.placeholder
echo "" > build/ramdisk/twPie/config/.placeholder
echo "" > build/ramdisk/twPie/data/.placeholder
echo "" > build/ramdisk/twPie/dev/.placeholder
echo "" > build/ramdisk/twPie/keydata/.placeholder
echo "" > build/ramdisk/twPie/keyrefuge/.placeholder
echo "" > build/ramdisk/twPie/lib/modules/.placeholder
echo "" > build/ramdisk/twPie/mnt/.placeholder
echo "" > build/ramdisk/twPie/omr/.placeholder
echo "" > build/ramdisk/twPie/proc/.placeholder
echo "" > build/ramdisk/twPie/storage/.placeholder
echo "" > build/ramdisk/twPie/sys/.placeholder
echo "" > build/ramdisk/twPie/system/.placeholder

echo "" > build/ramdisk/aospPie/acct/.placeholder
echo "" > build/ramdisk/aospPie/config/.placeholder
echo "" > build/ramdisk/aospPie/data/.placeholder
echo "" > build/ramdisk/aospPie/dev/.placeholder
echo "" > build/ramdisk/aospPie/mnt/.placeholder
echo "" > build/ramdisk/aospPie/oem/.placeholder
echo "" > build/ramdisk/aospPie/proc/.placeholder
echo "" > build/ramdisk/aospPie/storage/.placeholder
echo "" > build/ramdisk/aospPie/sys/.placeholder
echo "" > build/ramdisk/aospPie/system/.placeholder

echo "" > build/ramdisk/treblePie/ramdisk/acct/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/cache/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/carrier/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/config/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/data/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/dev/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/dqmdbg/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/efs/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/keydata/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/keyrefuge/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/lib/modules/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/oem/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/omr/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/proc/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/storage/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/sys/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/system/.placeholder
echo "" > build/ramdisk/treblePie/ramdisk/vendor/.placeholder




