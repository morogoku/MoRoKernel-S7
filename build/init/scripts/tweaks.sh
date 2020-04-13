#!/system/bin/sh
#
# tweaks by morogoku
#


echo "## -- Start tweaks" >> $LOG;


# disable cpuidle log
echo "0" > /sys/module/cpuidle_exynos64/parameters/log_en

# Turn off debugging for certain modules
echo "0" > /sys/module/alarm_dev/parameters/debug_mask
echo "0" > /sys/module/binder/parameters/debug_mask
echo "0" > /sys/module/binder_alloc/parameters/debug_mask
echo "0" > /sys/module/powersuspend/parameters/debug_mask
echo "0" > /sys/module/xt_qtaguid/parameters/debug_mask
echo "0" > /sys/module/lowmemorykiller/parameters/debug_level
echo "0" > /sys/module/kernel/parameters/initcall_debug


echo "## -- End tweaks" >> $LOG;
echo " " >> $LOG;

