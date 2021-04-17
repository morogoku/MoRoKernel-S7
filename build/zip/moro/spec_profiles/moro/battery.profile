#!/system/bin/sh
#
# Battery - rtakak Spectrum Profile For Moro Kernel v2
#

   # Little CPU
   echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
   echo "130000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
   echo "1482000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
   echo "92" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
   echo "19000 1066000:30000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
   echo "30000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
   echo "858000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
   echo "20000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
   echo "78 962000:85" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
   echo "40000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
   echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/mode
   echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost
   echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
   echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/param_index
   echo "40000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration

   # Big CPU
   echo "0" > /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster1_all_cores_max_freq
   echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
   echo "208000" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
   echo "1768000" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
   echo "94" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
   echo "60000 1248000:70000 1664000:25000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
   echo "30000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
   echo "1248000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
   echo "20000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
   echo "80 1040000:81 1352000:87 1664000:90" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
   echo "40000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
   echo "0" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/mode
   echo "0" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost
   echo "0" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
   echo "0" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/param_index
   echo "30000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration

   # BIG MAX FREQUENCY 
   echo "0" > /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster1_all_cores_max_freq

   # POWER EFFICIENT 
   chmod 644 /sys/module/workqueue/parameters/power_efficient
   echo "1" > /sys/module/workqueue/parameters/power_efficient

   # CPU BOOST 
   echo "0" > /sys/kernel/fp_boost/enabled
   echo "0" > /sys/kernel/cpu_input_boost/enabled

   # CPU HOTPLUG
   echo "1" > /sys/power/cpuhotplug/enabled

   # HMP
   echo "780" > /sys/kernel/hmp/up_threshold
   echo "300" > /sys/kernel/hmp/down_threshold

   # GPU
   echo "650" > /sys/devices/14ac0000.mali/max_clock
   echo "260" > /sys/devices/14ac0000.mali/min_clock
   echo "coarse_demand" > /sys/devices/14ac0000.mali/power_policy
   echo "1" > /sys/devices/14ac0000.mali/dvfs_governor
   echo "419" > /sys/devices/14ac0000.mali/highspeed_clock
   echo "95" > /sys/devices/14ac0000.mali/highspeed_load
   echo "1" /sys/devices/14ac0000.mali/highspeed_delay
   
   # GPU THERMALS 
   echo "1" > /sys/devices/14ac0000.mali/tmu
   echo "650" > /sys/devices/14ac0000.mali/throttling1
   echo "600" > /sys/devices/14ac0000.mali/throttling2
   echo "546" > /sys/devices/14ac0000.mali/throttling3
   echo "419" > /sys/devices/14ac0000.mali/throttling4
   echo "260" > /sys/devices/14ac0000.mali/tripping
   
   # IO Scheduler
   echo "cfq" > /sys/block/sda/queue/scheduler
   echo "128" > /sys/block/sda/queue/read_ahead_kb
   echo "0" > /sys/block/sda/queue/iostats
   echo "256" > /sys/block/sda/queue/nr_requests
   echo "cfq" > /sys/block/mmcblk0/queue/scheduler
   echo "128" > /sys/block/mmcblk0/queue/read_ahead_kb
   echo "0" > /sys/block/mmcblk0/queue/iostats
   echo "256" > /sys/block/mmcblk0/queue/nr_requests

   # Wakelocks
   echo "0" > /sys/module/wakeup/parameters/enable_sensorhub_wl
   echo "0" > /sys/module/wakeup/parameters/enable_ssp_wl
   echo "1" > /sys/module/wakeup/parameters/enable_bcmdhd4359_wl
   echo "1" > /sys/module/wakeup/parameters/enable_wlan_wake_wl
   echo "1" > /sys/module/wakeup/parameters/enable_bluedroid_timer_wl
   echo "3" > /sys/module/sec_battery/parameters/wl_polling
   echo "1" > /sys/module/sec_nfc/parameters/wl_nfc
   
   # VM
   echo "60" > /proc/sys/vm/swappiness
   echo "25" > /proc/sys/vm/dirty_ratio
   echo "5" > /proc/sys/vm/dirty_background_ratio
   echo "200" > /proc/sys/vm/dirty_expire_centisecs
   echo "500" > /proc/sys/vm/dirty_writeback_centisecs
   echo "7866" > /proc/sys/vm/min_free_kbytes
   echo "50" > /proc/sys/vm/overcommit_ratio
   echo "40" > /proc/sys/vm/vfs_cache_pressure
   echo "63078" > /proc/sys/vm/extra_free_kbytes
   
   # ENTROPY 
   echo "64" > /proc/sys/kernel/random/read_wakeup_threshold
   echo "896" > /proc/sys/kernel/random/write_wakeup_threshold

   # Misc
   echo "1" > /sys/module/sync/parameters/fsync_enabled
   echo "0" > /sys/kernel/dyn_fsync/Dyn_fsync_active
   echo "2" > /sys/kernel/power_suspend/power_suspend_mode
   echo "bic" > /proc/sys/net/ipv4/tcp_congestion_control

   # LMK
   echo "9694,19388,29082,38776,48470,58164" > /sys/module/lowmemorykiller/parameters/minfree

