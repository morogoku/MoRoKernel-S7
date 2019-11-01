#!/sbin/sh
#


# Mount system
export SYSTEM_ROOT=false

block=/dev/block/platform/155a0000.ufs/by-name/SYSTEM
SYSTEM_MOUNT=/system
SYSTEM=$SYSTEM_MOUNT

# Try to detect system-as-root through $SYSTEM_MOUNT/init.rc like Magisk does
# Mount whatever $SYSTEM_MOUNT is, sometimes remount is necessary if mounted read-only

grep -q "$SYSTEM_MOUNT.*\sro[\s,]" /proc/mounts && mount -o remount,rw $SYSTEM_MOUNT || mount -o rw "$block" $SYSTEM_MOUNT

# Remount /system to /system_root if we have system-as-root and bind /system to /system_root/system (like Magisk does)
# For reference, check https://github.com/topjohnwu/Magisk/blob/master/scripts/util_functions.sh
if [ -f /system/init.rc ]; then
  mkdir /system_root
  mount --move /system /system_root
  mount -o bind /system_root/system /system
  export SYSTEM_ROOT=true
fi


file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

SDK="$(file_getprop /system/build.prop ro.build.version.sdk)"


# Show GPU
if [ -f /system/framework/com.samsung.device.jar ]; then

	if [ $SDK == 28 ]; then
		echo "show=1" > /tmp/aroma/gpu_driver.prop
	else
		echo "show=0" > /tmp/aroma/gpu_driver.prop
	fi
else

	echo "show=0" > /tmp/aroma/gpu_driver.prop
fi


# Is Treble Q
if [ "$(ls /dev/block/platform/155a0000.ufs/by-name | grep 'VENDOR')" == "VENDOR" ] && [ ! -f /system/framework/com.samsung.device.jar ]; then

	if [ $SDK == 29 ]; then
		echo "trebleq=1" > /tmp/aroma/trebleq.prop
	else
		echo "trebleq=0" > /tmp/aroma/trebleq.prop
	fi
else
	echo "trebleq=0" > /tmp/aroma/trebleq.prop
fi


# Is Lineage 17
if [ "$(ls /dev/block/platform/155a0000.ufs/by-name | grep 'VENDOR')" != "VENDOR" ] && [ ! -f /system/framework/com.samsung.device.jar ]; then

	if [ $SDK == 29 ]; then
		echo "los17=1" > /tmp/aroma/los17.prop
	else
		echo "los17=0" > /tmp/aroma/los17.prop
	fi
else
	echo "los17=0" > /tmp/aroma/los17.prop
fi


# Umount
umount -l /system_root 2>/dev/null
umount -l /system 2>/dev/null



