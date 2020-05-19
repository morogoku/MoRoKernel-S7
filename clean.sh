#!/bin/bash
#
#
# MoRoKernel Cleaning Script 1.0
#


# Clean Build Data
make clean
make ARCH=arm64 distclean

rm -f $PWD/build/*.img 2>/dev/null
rm -f $PWD/arch/arm64/boot/dts/*.dtb 2>/dev/null
rm -f $PWD/arch/arm64/configs/tmp_defconfig 2>/dev/null
rm -rf $PWD/arch/arm64/boot/dtb 2>/dev/null
rm -f $PWD/build/*.zip 2>/dev/null
rm -rf $PWD/build/kernel-temp 2>/dev/null
rm -rf $PWD/build/temp 2>/dev/null
rm -rf $PWD/net/wireguard 2>/dev/null

rm -f ./*.log

echo "" > $PWD/build/zip/moro/files/.placeholder

echo "" > build/ramdisk/twQ/ramdisk/apex/.placeholder
echo "" > build/ramdisk/twQ/ramdisk/config/.placeholder
echo "" > build/ramdisk/twQ/ramdisk/debug_ramdisk/.placeholder
echo "" > build/ramdisk/twQ/ramdisk/dev/.placeholder
echo "" > build/ramdisk/twQ/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/twQ/ramdisk/proc/.placeholder
echo "" > build/ramdisk/twQ/ramdisk/sys/.placeholder

echo "" > build/ramdisk/twPie/ramdisk/acct/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/cache/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/config/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/data/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/dev/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/keydata/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/keyrefuge/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/lib/modules/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/omr/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/proc/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/storage/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/sys/.placeholder
echo "" > build/ramdisk/twPie/ramdisk/system/.placeholder

echo "" > build/ramdisk/twOreo/ramdisk/acct/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/cache/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/config/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/data/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/dev/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/lib/modules/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/proc/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/storage/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/sys/.placeholder
echo "" > build/ramdisk/twOreo/ramdisk/system/.placeholder

echo "" > build/ramdisk/los16/ramdisk/acct/.placeholder
echo "" > build/ramdisk/los16/ramdisk/config/.placeholder
echo "" > build/ramdisk/los16/ramdisk/data/.placeholder
echo "" > build/ramdisk/los16/ramdisk/dev/.placeholder
echo "" > build/ramdisk/los16/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/los16/ramdisk/oem/.placeholder
echo "" > build/ramdisk/los16/ramdisk/proc/.placeholder
echo "" > build/ramdisk/los16/ramdisk/storage/.placeholder
echo "" > build/ramdisk/los16/ramdisk/sys/.placeholder
echo "" > build/ramdisk/los16/ramdisk/system/.placeholder

echo "" > build/ramdisk/los17/ramdisk/apex/.placeholder
echo "" > build/ramdisk/los17/ramdisk/debug_ramdisk/.placeholder
echo "" > build/ramdisk/los17/ramdisk/dev/.placeholder
echo "" > build/ramdisk/los17/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/los17/ramdisk/proc/.placeholder
echo "" > build/ramdisk/los17/ramdisk/sys/.placeholder

echo "" > build/ramdisk/treble/ramdisk/acct/.placeholder
echo "" > build/ramdisk/treble/ramdisk/cache/.placeholder
echo "" > build/ramdisk/treble/ramdisk/carrier/.placeholder
echo "" > build/ramdisk/treble/ramdisk/config/.placeholder
echo "" > build/ramdisk/treble/ramdisk/data/.placeholder
echo "" > build/ramdisk/treble/ramdisk/dev/.placeholder
echo "" > build/ramdisk/treble/ramdisk/dqmdbg/.placeholder
echo "" > build/ramdisk/treble/ramdisk/efs/.placeholder
echo "" > build/ramdisk/treble/ramdisk/keydata/.placeholder
echo "" > build/ramdisk/treble/ramdisk/keyrefuge/.placeholder
echo "" > build/ramdisk/treble/ramdisk/lib/modules/.placeholder
echo "" > build/ramdisk/treble/ramdisk/mnt/.placeholder
echo "" > build/ramdisk/treble/ramdisk/oem/.placeholder
echo "" > build/ramdisk/treble/ramdisk/omr/.placeholder
echo "" > build/ramdisk/treble/ramdisk/proc/.placeholder
echo "" > build/ramdisk/treble/ramdisk/storage/.placeholder
echo "" > build/ramdisk/treble/ramdisk/sys/.placeholder
echo "" > build/ramdisk/treble/ramdisk/system/.placeholder
echo "" > build/ramdisk/treble/ramdisk/vendor/.placeholder

