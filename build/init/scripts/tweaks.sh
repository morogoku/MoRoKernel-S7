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

# CPU
echo "338000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "416000" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq

# HMP
echo "600" > /sys/kernel/hmp/up_threshold
echo "235" > /sys/kernel/hmp/down_threshold

# Wakelock
echo "3" > /sys/module/sec_battery/parameters/wl_polling
echo "1" > /sys/module/sec_nfc/parameters/wl_nfc

# Read Ahead
echo "2048" > /sys/block/sda/queue/read_ahead_kb
echo "2048" > /sys/block/mmcblk0/queue/read_ahead_kb

# Misc Options
echo "0" > /sys/kernel/dyn_fsync/Dyn_fsync_active
echo "0" > /sys/module/sync/parameters/fsync_enabled
echo "2" > /sys/kernel/power_suspend/power_suspend_mode
echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control

# LMK
echo "9694,19388,29082,38776,48470,58164" > /sys/module/lowmemorykiller/parameters/minfree
   
   
echo "## -- End tweaks" >> $LOG;
echo " " >> $LOG;

