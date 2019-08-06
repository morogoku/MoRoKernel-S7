#!/sbin/sh
#

mount -t auto /system

file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

SDK="$(file_getprop /system/build.prop ro.build.version.sdk)"


if [ -f /system/framework/com.samsung.device.jar ]; then

	if [ $SDK == 28 ]; then
		echo "show=1" > /tmp/aroma/gpu_driver.prop
	else
		echo "show=0" > /tmp/aroma/gpu_driver.prop
	fi
else

	echo "show=0" > /tmp/aroma/gpu_driver.prop
fi
	



