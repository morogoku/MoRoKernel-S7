# Performance Profile

   # Little CPU
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
   echo interactive > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
   echo 130000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
   echo 1690000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
   echo 74 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
   echo "19000" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
   echo 10000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
   echo 754000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
   echo 10000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
   echo "75" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
   echo 105000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/mode
   echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/mode
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost
   echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
   echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/param_index
   echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/param_index
   chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration
   echo 1000000 > /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration

   # Big CPU
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
   echo interactive > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
   echo 208000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
   echo 2600000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
   echo 80 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
   echo "20000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
   echo 10000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
   echo 1040000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
   echo 10000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
   echo "75" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
   echo 90000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/mode
   echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/mode
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost
   echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
   echo 1 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/param_index
   echo 0 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/param_index
   chmod 644 /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration
   echo 1000000 > /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration

   # CPU HOTPLUG
   echo 1 > /sys/power/cpuhotplug/enabled

   # GPU
   chmod 644 /sys/devices/14ac0000.mali/max_clock
   echo 650 > /sys/devices/14ac0000.mali/max_clock
   chmod 644 /sys/devices/14ac0000.mali/min_clock
   echo 260 > /sys/devices/14ac0000.mali/min_clock
   chmod 644 /sys/devices/14ac0000.mali/power_policy
   echo coarse_demand > /sys/devices/14ac0000.mali/power_policy
   chmod 644 /sys/devices/14ac0000.mali/dvfs_governor
   echo 1 > /sys/devices/14ac0000.mali/dvfs_governor
   chmod 644 /sys/devices/14ac0000.mali/highspeed_clock
   echo 419 > /sys/devices/14ac0000.mali/highspeed_clock
   chmod 644 /sys/devices/14ac0000.mali/highspeed_load
   echo 95 > /sys/devices/14ac0000.mali/highspeed_load
   chmod 644 /sys/devices/14ac0000.mali/highspeed_delay
   echo 1 > /sys/devices/14ac0000.mali/highspeed_delay

   # IO Scheduler
   echo zen > /sys/block/sda/queue/scheduler
   echo 1024 > /sys/block/sda/queue/read_ahead_kb
   echo zen > /sys/block/mmcblk0/queue/scheduler
   echo 2048 > /sys/block/mmcblk0/queue/read_ahead_kb

   # Misc
   echo 0 > /sys/module/sync/parameters/fsync_enabled
   echo 0 > /sys/kernel/dyn_fsync/Dyn_fsync_active
   echo 0 > /sys/kernel/sched/gentle_fair_sleepers
   echo 1 > /sys/kernel/sched/arch_power
   echo 2 > /sys/kernel/power_suspend/power_suspend_mode
   echo 0 > /sys/class/lcd/panel/smart_on
   echo westwood > proc/sys/net/ipv4/tcp_congestion_control

   # LMK
   echo "18432,23040,27648,32256,56064,81152" > /sys/module/lowmemorykiller/parameters/minfree
