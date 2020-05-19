#!/system/bin/sh
#
# Gaming
#

   # Little CPU
   echo "interactiveS9" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
   echo "442000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
   echo "1586000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
   echo "78" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
   echo "19000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
   echo "10000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
   echo "650000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
   echo "10000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
   echo "75" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
   echo "90000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
   echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/mode
   echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost
   echo "1" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
   echo "0" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/param_index
   echo "100000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration

   # Big CPU
   echo "1" > /sys/devices/system/cpu/cpufreq/mp-cpufreq/cluster1_all_cores_max_freq
   echo "interactiveS9" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
   echo "720000" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
   echo "2600000" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
   echo "82" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
   echo "19000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
   echo "10000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
   echo "1040000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
   echo "10000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
   echo "75" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
   echo "90000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
   echo "0" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/mode
   echo "0" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost
   echo "1" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
   echo "0" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/param_index
   echo "100000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration

   # CPU HOTPLUG
   echo "1" > /sys/power/cpuhotplug/enabled

   # HMP
   echo "524" > /sys/kernel/hmp/up_threshold
   echo "214" > /sys/kernel/hmp/down_threshold

   # GPU
   echo "806" > /sys/devices/14ac0000.mali/max_clock
   echo "260" > /sys/devices/14ac0000.mali/min_clock
   echo "coarse_demand" > /sys/devices/14ac0000.mali/power_policy
   echo "1" > /sys/devices/14ac0000.mali/dvfs_governor
   echo "600" > /sys/devices/14ac0000.mali/highspeed_clock
   echo "40" > /sys/devices/14ac0000.mali/highspeed_load
   echo "1" /sys/devices/14ac0000.mali/highspeed_delay

   # IO Scheduler
   echo "fiops" > /sys/block/sda/queue/scheduler
   echo "2048" > /sys/block/sda/queue/read_ahead_kb
   echo "fiops" > /sys/block/mmcblk0/queue/scheduler
   echo "2048" > /sys/block/mmcblk0/queue/read_ahead_kb

   # Wakelocks
   echo "1" > /sys/module/wakeup/parameters/enable_ssp_wl
   echo "1" > /sys/module/wakeup/parameters/enable_sensorhub_wl
   echo "10" > /sys/module/sec_battery/parameters/wl_polling
   echo "2" > /sys/module/sec_nfc/parameters/wl_nfc

   # Misc
   echo "0" > /sys/module/sync/parameters/fsync_enabled
   echo "1" > /sys/kernel/dyn_fsync/Dyn_fsync_active
   echo "3" > /sys/kernel/power_suspend/power_suspend_mode
   echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control

   # LMK
   echo "9694,19388,29082,38776,48470,58164" > /sys/module/lowmemorykiller/parameters/minfree

