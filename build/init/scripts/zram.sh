#!/system/bin/sh
#
# zram script by morogoku
#

# If the rom is not Floyd and Lineage 18, create zram
if [ ! -e /system/vendor/etc/init/init.custom.rc ] && [ ! -d /system/etc/init/hw ]; then
	echo "## -- Start ZRam support" >> $LOG;

	# Zram0
	swapoff /dev/block/zram0 > /dev/null 2>&1
	echo 1 > /sys/block/zram0/reset > /dev/null 2>&1
	echo 2147483648 > /sys/block/zram0/disksize
	mkswap /dev/block/zram0
	swapon /dev/block/zram0

	echo "## -- End ZRam support" >> $LOG;
	echo " " >> $LOG;
fi
