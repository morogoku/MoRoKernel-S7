#!/sbin/sh
#
# MoRoKernel Flash script 1.0
#
# Thanks to dwander for original script
# 

bootloader=`getprop ro.bootloader`
variant=${bootloader:0:4}

cd /tmp/moro

tar -Jxf kernel.tar.xz $variant-r22-boot.img

dd of=/dev/block/platform/155a0000.ufs/by-name/BOOT if=/tmp/moro/$variant-r22-boot.img


